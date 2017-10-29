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


If you get errors like `error: Server does not allow request for unadvertised object` then delete homebrew's cached ldc-weka repo and try again:
```
# prints the directory, should look something like $HOME/Library/Caches/Homebrew/ldc-weka--git
brew --cache ldc-weka
rm -rf directory_from_above
```
