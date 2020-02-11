import re
# based on: https://qna.habr.com/q/709639
regex = r'[0-9]{,}(?=x)|[-|+][0-9]{1,}'
test_str = '5x^2-5x+4'
matches = re.finditer(regex, test_str, re.MULTILINE)

for _, match in enumerate(matches, start = 1 ):
  match = match.group(0)
  if match != '' :
    print('{}'.format(match))

# comprehension - does not work ? reset ?
matches = re.finditer(regex, test_str, re.MULTILINE)
o = [x.group() for y, x in enumerate(matches,start = 1) if x.group() != '']
print(o)

matches = re.finditer(regex, test_str, re.MULTILINE)
o  = map(int, (x.group() for y, x in enumerate(matches) if x.group() != ''))
print(o)
