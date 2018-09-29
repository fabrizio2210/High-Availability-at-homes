from ansible.module_utils._text import to_native
from ansible import errors

__metaclass__ = type

def find(dictionary, key):
  for k, v in dictionary.iteritems():
    if k == key:
      yield v
    elif isinstance(v, dict):
      for result in find(v,key):
        yield result
    elif isinstance(v, list):
      for d in v:
        if isinstance(d, dict):
          for result in find(d, key):
            yield result

def key_exists(_hash, _key):
  for v in find(_hash, _key):
    return True
  return False

class TestModule(object):
  ''' hash test '''

  def tests(self):
    return {
      # Does the key exists in the hash?
      'keyexists': key_exists,
    }

