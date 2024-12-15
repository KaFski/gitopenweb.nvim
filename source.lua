gitopenweb = package.loaded['gitopenweb']
gitopenweb.cleanup()
package.loaded['gitopenweb'] = nil

require('gitopenweb')
print("loaded gitopenweb")
