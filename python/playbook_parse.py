import yaml
import sys
import pprint
input_file = sys.argv[1]
f = open(input_file)
c = yaml.load(f, Loader=yaml.FullLoader)
pp = pprint.PrettyPrinter(indent=2)
# TypeError: 'module' object is not callable
pp.pprint(c)
tasks = c['tasks']
for cnt in range(len(tasks)):
  task = tasks[cnt]

  pp.pprint(task['package'])
  try:
    data = task['package']
    pp.pprint(data)
    values = dict(item.split('=') for item in data.split('  *'))
    pp.pprint(values['name'])
  except TypeError as e:
    print(str(e))
    # string indices must be integers
    # because the value of the package is tokenized by ansible not yaml
    pass
  except ValueError as e:
    print(str(e))
    # TODO: ValueError: dictionary update sequence element #0 has length 3; 2 is required
    pass
  
