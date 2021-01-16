# Tester Command

Tester is command in shell to test the command.

## Setup

Save file as `tester` name, then put in your $PATH variable.

chmod +x tester
sudo mv tester -t /usr/local/bin
# or
[ -d ~/bin ] && mv tester -t ~/bin

## Getting Started

Example 2.

```
tester "echo 1" -o 1
```

Execute this command `echo 1` and expect the output is `1`.

The output:

```
$ tester "echo 1" -o 1
---
echo 1
---
Success. Command return: 0
Success. Output match:
1

$
```

Example 2.

```
tester "touch a.jpg" -fe 'a.jpg'
```

Execute this command `touch a.jpg` and expect the generated file named `a.jpg`.

The output:

```
$ tester "touch a.jpg" -fe 'a.jpg'
---
touch a.jpg
---
Success. Command return: 0
Success. File exists: a.jpg

$
```
