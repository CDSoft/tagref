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

help.name "Tagref"
help.description "$name installation"

var "builddir" ".build"
clean "$builddir"

local targets = F(require "sys".targets):map(F.partial(F.nth, "name"))
local target, ext = nil, ""
F(arg) : foreach(function(a)
    if targets:elem(a) then
        if target then F.error_without_stack_trace("multiple target definition", 2) end
        target = a
        if target:match"windows" then ext = ".exe" end
    else
        F.error_without_stack_trace(a..": unknown argument")
    end
end)

rule "luaxc" {
    description = "LUAXC $out",
    command = "luaxc $arg -q -o $out $in",
}

local tagref = build("$builddir/tagref"..ext) {
    "luaxc",
    ls "src/*.lua",
    arg = target and {"-t", target},
}

install "bin" { tagref }

default { tagref }
