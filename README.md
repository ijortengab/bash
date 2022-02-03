# Bash Script Collection

## Functions

List all functions.

### ArrayDiff

Computes the difference of arrays.

```sh
filename=array-diff.function.sh
```

### ArrayRemoveAll

Shift all element from the array.

```sh
filename=array-remove-all.function.sh
```

### ArrayRemove

Shift an element from the array, only first match.

```sh
filename=array-remove.function.sh
```

### ArraySearch

Find element in Array. Searches the array for a given value and returns the first corresponding key if successful.

```sh
filename=array-search.function.sh
```

### ArrayShift

Shift an element off the beginning of array.

```sh
filename=array-shift.function.sh
```

### ArrayUnique

Removes duplicate values from an array.

```sh
filename=array-unique.function.sh
```

### ArrayUnset

Shift an element from the array by its key/index number.

```sh
filename=array-unset.function.sh
```

### VarDump()

Variable Dump for Debugging.

```sh
filename=var-dump.function.sh
```

## Commands

### backup.sh

Provide fast way to save backup of file.

```sh
filename=backup.sh
```

### command-keep-alive.sh

Keep command keep alive even it destroyed because of something.

```sh
filename=command-keep-alive.sh
```

### reset-mtime.sh

Reset the modification time of file if there is date information in filename.

```sh
filename=reset-mtime.sh
```

### tester

Test the command then set the expected. [README](https://github.com/ijortengab/bash/tree/master/commands/tester/dev)

```sh
filename=tester.sh
```

### ttw

Bulk trim trailing whitespace of files.

```sh
filename=ttw.sh
```

### Install

Copy variable `filename` from code above, then paste in Terminal, then use code below.

Copy function to Clipboard (for Cygwin users):

```
wget -qO- https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename | clip.exe
```

```
curl https://raw.githubusercontent.com/ijortengab/bash/master/functions/array-shift.function.sh | clip.exe
```

Show function in Terminal:

```
wget -qO- https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename
```

```
curl https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename
```

Download then put command in `$PATH`.

```
wget https://raw.githubusercontent.com/ijortengab/bash/master/commands/$filename
chmod a+x $filename
mv $filename -t /usr/local/bin
```

```
curl -O https://raw.githubusercontent.com/ijortengab/bash/master/commands/$filename
chmod a+x $filename
mv $filename -t /usr/local/bin
```
