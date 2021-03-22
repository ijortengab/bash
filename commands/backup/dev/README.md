# Backup File

```
touch myfile
backup myfile
```

Command above will move `myfile` to `myfile~1`

```
touch myfile.png
backup myfile.png
```

Command above will move `myfile.png` to `myfile~1.png`

```
touch myimage.jpg \
      myimage~1.jpg \
      myimage~2.jpg
backup myimage.jpg
```

Command above will move `myimage.jpg` to `myimage~3.jpg`

## Features

Use options `-c|--copy` to copy the original source instead of moving it.

All operands and standard input will interprets as file.
