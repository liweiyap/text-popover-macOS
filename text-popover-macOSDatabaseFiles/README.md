This is the directory where all .db files used by the app are stored. All .db files can be created, modified, or deleted from within the app. Do __not__ navigate to this directory in Finder and edit the .db files from outside the app.

If the .db files are edited whilst the app is still running, it might cause the app to crash. If that happens:

* Redo the changes to the .db files and restart the app.
* If the app still crashes, then delete all .db files that were edited from outside the app and restart the app.

Note: the default database `german-idioms.db` is always generated anew every time the app is started. The title of its table is "Redewendungen". Do __not__ change it.
