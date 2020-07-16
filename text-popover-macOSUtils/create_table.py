from bs4 import BeautifulSoup as soup
from urllib.request import urlopen as uReq
import re
import sqlite3
from typing import Tuple
import os


PATTERN_SQUARE_PARENTHESES = r'\[.*?\]'
ABBREV_SINGLE = set(['bzw', '(bzw', 'usw', '(usw', 'vgl', '(vgl'])
ABBREV_DOUBLE = set(['z', '(z', 'd', '(d', 'u', '(u'])  # z. B., d. h., u. a.
MEANING_CHANGE = set(['(ursprünglich:)'])
MEANING_VARIATION = set(['Auch:'])
ORDINAL_NOUNS = set(['Jahrhundert'])
LAST_EXPRESSION = 'Zwischen den Jahren'

def check_for_abbrev(explanation: str, elaboration: str) -> Tuple[str, str]:
    while (explanation.split()[-1] in ABBREV_SINGLE or explanation.split()[-1] in ABBREV_DOUBLE):
        if (explanation.split()[-1] in ABBREV_SINGLE):
            elaboration_split = elaboration.split('.', 1)
            explanation = explanation + ". " + elaboration_split[0]
            elaboration = elaboration_split[1].strip()
        if (explanation.split()[-1] in ABBREV_DOUBLE):
            elaboration_split = elaboration.split('.', 2)
            explanation = explanation + ". " + elaboration_split[0] + "." + elaboration_split[1]
            elaboration = elaboration_split[2].strip()
    return explanation, elaboration

def check_for_missing_statements(elaboration: str) -> str:
    if (elaboration != '' and elaboration[-1] == ':'):
        elaboration = ''
    return elaboration

def check_for_exclamations(explanation: str, elaboration: str) -> Tuple[str, str]:
    explanation_split = explanation.split('!', 1)
    if (len(explanation_split) > 1 and explanation_split[1][0] != ';'):
        explanation = explanation_split[0] + "!"
        elaboration = explanation_split[1].strip() + ". " + elaboration
    return explanation, elaboration.strip()

def check_for_ellipsis(explanation: str, elaboration: str) -> Tuple[str, str]:
    elaboration_split = elaboration.split()
    if (elaboration_split[0] == '...'):
        explanation = explanation + ' ...'  # space because see "Ihr müsst endlich in die Hufe kommen"
        elaboration = elaboration[4:]
    return explanation, elaboration

def check_meaning(explanation: str, elaboration: str) -> Tuple[str, str]:
    if (explanation.split()[0] in MEANING_CHANGE or elaboration.split()[0] in MEANING_VARIATION or elaboration.split()[0] in ORDINAL_NOUNS):
        elaboration_split = elaboration.split('.', 1)
        explanation = explanation + ". " + elaboration_split[0]
        if (len(elaboration_split) == 1):
            elaboration = ''
        else:
            elaboration = elaboration_split[1].strip()
    return explanation, elaboration

def check_for_trailing_punctuation(explanation: str, elaboration: str, opening: str, closing: str) -> Tuple[str, str]:
    assert(len(opening) == 1 and len(closing) == 1)
    if (len(elaboration) != 0 and
        elaboration[0] == opening and (elaboration[-2] == closing or elaboration[-1] == closing) and
        elaboration.count(opening) == 1 and elaboration.count(opening) == 1):
        elaboration = re.sub('[' + opening + closing + ']', '', elaboration)
    else:
        while (explanation != '' and explanation.count(opening) > explanation.count(closing) and
               elaboration != '' and elaboration.count(closing) > 0):
            elaboration_split = elaboration.split(closing, 1)
            if (elaboration_split[0] == ''):
                explanation = explanation + "." + closing
            else:
                explanation = explanation + ". " + elaboration_split[0].strip() + closing
            elaboration = elaboration_split[1].strip()
    return explanation, elaboration

def main() -> None:
    db_connection = sqlite3.connect('/Users/leewayleaf/Documents/Repositories/text-popover-macOS/text-popover-macOSUtils/redewendungen.db')
    cursor = db_connection.cursor()
    cursor.execute("DROP TABLE IF EXISTS Redewendungen")
    cursor.execute("""CREATE TABLE Redewendungen (
                        Expression TEXT,
                        Explanation TEXT,
                        Elaboration TEXT
                      )""")
    
    page_url = "https://de.wikipedia.org/wiki/Liste_deutscher_Redewendungen"
    uClient = uReq(page_url)
    page_soup = soup(uClient.read(), "html.parser")
    uClient.close()
    
    containers = page_soup.findAll("ul")
    
    for container in containers:
        subcontainer = container.findAll("li")
        for bullet in subcontainer:
            # strip HTML tags
            bullet_stripped = bullet.get_text()
            
            # remove reference/citations nos.
            bullet_stripped = re.sub(PATTERN_SQUARE_PARENTHESES, '', bullet_stripped)
            
            # remove any LaTeX formatting
            bullet_stripped = re.sub('{[^}]+}', '', bullet_stripped)
            
            # replace any multiple whitespace with a single whitespace
            bullet_stripped = ' '.join(bullet_stripped.split())
            
            # split into expression, explanation, and elaboration
            bullet_stripped_split = bullet_stripped.split(' – ', 1)
            expression = bullet_stripped_split[0]  # Everything before the first –
            if (len(bullet_stripped_split) == 2):
                try:
                    explanation_and_elaboration = bullet_stripped_split[1].split('.', 1)
                    explanation = explanation_and_elaboration[0].strip()  # Everything after the first – and before the first .
                    elaboration = explanation_and_elaboration[1].strip()  # Everything after the first .
                    explanation, elaboration = check_for_abbrev(explanation, elaboration)
                    elaboration = check_for_missing_statements(elaboration)
                    explanation, elaboration = check_for_exclamations(explanation, elaboration)
                    if (elaboration != ''):
                        explanation, elaboration = check_for_ellipsis(explanation, elaboration)
                        explanation, elaboration = check_meaning(explanation, elaboration)
                        explanation, elaboration = check_for_trailing_punctuation(explanation, elaboration, '(', ')')
                        explanation, elaboration = check_for_trailing_punctuation(explanation, elaboration, '„', '“')
                except IndexError:
                    explanation = bullet_stripped_split[1]
                    elaboration = ''
            else:
                if (len(expression.split(':', 1)) == 2):
                    expression_split = expression.split(':', 1)
                    expression = expression_split[0].strip()
                    explanation = expression_split[1].strip()
                    elaboration = ''
                else:
                    explanation = ''
                    elaboration = ''
            
            # handle specific cases
            if (expression == 'Etwas in Kauf nehmen'):
                elaboration = ''
            elif (expression == 'Null-acht-fünfzehn/fuffzehn' or
                  expression == 'Den Schuh muss ich mir anziehen' or
                  expression == 'So wird ein Schuh draus'):
                continue
            elif (expression == 'Man hat ihm Sand in die Augen gestreut. Man hat ihn getäuscht oder irregeführt. Schon in der Antike benutzte Redewendung, vermutlich aus der Fechtersprache, wonach der Gegner durch das Werfen von Sand ins Gesicht quasi wehrlos wurde.'):
                expression_split = expression.split('.')
                expression = expression_split[0]
                explanation = expression_split[1].strip()
                elaboration = expression_split[2].strip() + "."
            elif (expression == 'Herein wenn’s kein Schneider ist'):
                explanation = explanation + ". " + elaboration
                elaboration = ''
            elif (expression == 'Wer sich hinter schwedischen Gardinen befindet, sitzt im Gefängnis. Schwedischer Stahl galt lange Zeit als besonders robust und wurde daher gern für Gitterstäbe verwendet.'):
                expression_split = expression.split('.')
                expression = expression_split[0] + "."
                explanation = ''
                elaboration = expression_split[1].strip() + "."   
            elif (expression == 'Stein des Anstoßes, Auslöser eines Streits oder Ärgernisses; aus'):
                elaboration = explanation
                expression_split = expression.split(',')
                expression = expression_split[0]
                expression_split_split = expression_split[1].strip().split(';')
                explanation = expression_split_split[0]
                elaboration = expression_split_split[1].strip() + ": " + elaboration
            elif (expression == 'Stein und Bein schwören, einen Schwur besonders bekräftigen; wird oftmals auf mittelalterliche Schwurrituale auf Altarstein und Reliquie („Bein“ im Sinne von Knochen) zurückgeführt, wahrscheinlicher ist jedoch, dass einfach auf die besondere Härte der genannten Dinge Bezug genommen wird'):
                expression_split = expression.split(',', 1)
                expression = expression_split[0]
                explanation_and_elaboration = expression_split[1].strip()
                explanation_and_elaboration_split = explanation_and_elaboration.split(';')
                explanation = explanation_and_elaboration_split[0]
                elaboration = explanation_and_elaboration_split[1].strip()
            elif (expression == 'Etwas in trockenen Tüchern haben / etwas gesichert / erledigt haben'):
                elaboration = explanation
                expression_split = expression.split(' / ', 1)
                expression = expression_split[0]
                explanation = expression_split[1]
            elif (expression == 'Jemandem das Wasser nicht reichen können (seit dem 16. Jahrhundert)– ihm weit unterlegen sein. Im Mittelalter, als noch mit den Fingern gegessen wurde, reichten Diener nach dem Essen tief verneigt den Gästen Wasser zum Händewaschen. War dies schon erniedrigend, wie tief stand erst einer im Ansehen, der nicht einmal mehr diese Aufgabe übernehmen durfte.'):
                expression_split = expression.split('–')
                expression = expression_split[0]
                explanation_and_elaboration = expression_split[1].strip()
                explanation_and_elaboration_split = explanation_and_elaboration.split('.', 1)
                explanation = explanation_and_elaboration_split[0]
                elaboration = explanation_and_elaboration_split[1].strip()
            elif (expression == 'Da habe ich mit Zitronen gehandelt'):
                elaboration = elaboration[:-1] + "."
            
            cursor.execute("INSERT INTO Redewendungen VALUES (:expr, :expl, :elab)",
                            {'expr': expression, 'expl': explanation, 'elab': elaboration})
            
            if (expression == LAST_EXPRESSION):
                break
        else:
            continue  # executed only if the inner FOR loop did not break
        break  # executed only if the inner FOR loop did break
    
    db_connection.commit()

#--------------------------#

if __name__ == "__main__":
    main()
