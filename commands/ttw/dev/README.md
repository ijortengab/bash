# Trim Trailing Whitespace Command

TTW per context.

```
ttw git
```

Command above is shortcut for:

```
git ls-files | while IFS= read -r path; do sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
```

```
ttw php
```

Command above is shortcut for:

```
git ls-files | while IFS= read -r path; do sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
```
