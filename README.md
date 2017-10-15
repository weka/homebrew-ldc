# homebrew-ldc
To use this tap:
```
brew tap weka-io/homebrew-ldc
brew install ldc-weka
```
Or, to use the latest version:
```
brew install --HEAD ldc-weka
```

If you get git errors about missing revisions, delete homebrew's cached ldc-weka repo and try again:
```
# prints the directory, should look something like $HOME/Library/Caches/Homebrew/ldc-weka--git
brew --cache ldc-weka
rm -rf directory_from_above
```
