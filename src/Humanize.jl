#----------------------------------------------------------------------
# Humanize.jl    https://github.com/IainNZ/Humanize.jl
# Based on jmoiron's humanize Python library (MIT licensed):
#  https://github.com/jmoiron/humanize/blob/master/humanize/filesize.py
# All original code is (c) Iain Dunning and MIT licensed.
#----------------------------------------------------------------------

module Humanize

include("filesize.jl")
export naturalsize

end