# Tester Command

Tester is command in shell to test the command then set the expected.

## Setup

Download with curl.

```
curl -L https://git.io/tester.sh -o tester
```

or wget.

```
wget https://git.io/tester.sh -O tester
```

Save file as `tester` name, then put in your $PATH variable.

```
chmod +x tester
sudo mv tester -t /usr/local/bin
# or
[ -d ~/bin ] && mv tester -t ~/bin
```

## Getting Started

Example 1.

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

Example 3.

```
tester "touch a.jpg; touch b.jpg; touch c.jpg; echo 1; rm c.jpg" \
    -o 1 \
    -fe 'a.jpg' \
    -fe 'b.jpg' \
    -fne 'c.jpg'
```

Execute this command `touch a.jpg; touch b.jpg; touch c.jpg; echo 1; rm c.jpg` and set the expects result in options.

The output:

```
$ tester "touch a.jpg; touch b.jpg; touch c.jpg; echo 1; rm c.jpg" -o 1 -fe 'a.jpg' -fe 'b.jpg' -fne 'c.jpg'
---
touch a.jpg; touch b.jpg; touch c.jpg; echo 1; rm c.jpg
---
Success. Command return: 0
Success. Output match:
1
Success. File exists: a.jpg
Success. File exists: b.jpg
Success. File not exists: c.jpg

$
```
