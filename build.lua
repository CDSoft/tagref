section [[
This file is part of Tagref.

Tagref is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Tagref is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Tagref.  If not, see <https://www.gnu.org/licenses/>.

For further information about Tagref you can visit
http://cdelord.fr/tagref
]]

local F = require "F"
local sys = require "sys"

help.name "Tagref"
help.description "$name installation"

local target, args = target(arg)
if #args > 0 then
    F.error_without_stack_trace(F.unwords(args)..": unexpected arguments")
end

var "builddir" (".build"/(target and target.name))
clean "$builddir"

rule "luaxc" {
    description = "LUAXC $out",
    command = "luax compile $arg -q -o $out $in",
}

local tagref = build("$builddir/tagref"..(target or sys).exe) {
    "luaxc",
    ls "src/*.lua",
    arg = { "-b", "-t", target and target.name or "native" },
}

install "bin" { tagref }

default { tagref }
