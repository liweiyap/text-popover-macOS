# text-popover-macOSDatabaseFiles

## .db files

This is the directory where all .db files used by the app are stored. All .db files can be created, modified, or deleted from within the app. Do __not__ navigate to this directory in Finder and edit the .db files from outside the app.

If the .db files are edited whilst the app is still running, it might cause the app to crash. If that happens:

* Redo the changes to the .db files and restart the app.
* If the app still crashes, then delete all .db files that were edited from outside the app and restart the app.

Note: the default database `german-idioms.db` is always generated anew every time the app is started. The title of its table is "Redewendungen". Do __not__ change it.

## `run_create_database_german_idioms_impl.sh`

This script is called from within the app to create the default database `german-idioms.db` using `create_database_german_idioms_impl.py`. Before running the app, make sure to first change the value of `EXTERNAL_PYTHON_EXEC` in the script to the correct path to your Python executable.

To check the correct path, run `which python3` on the Terminal (i.e. from outside Xcode).

Make sure that your Python executable has already had the library [`Beautiful Soup`](https://pypi.org/project/beautifulsoup4/) installed.
