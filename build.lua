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
https://github.com/cdsoft/tagref
]]

help.name "Tagref"
help.description "$name installation"

var "builddir" ".build"
clean "$builddir"

build.luax.add_global "flags" "-q"

local sources = { ls "src/*.lua" }

local tagref = build.luax.native "$builddir/tagref" { sources }

install "bin" { tagref }

default { tagref }

require "build-release" {
    name = "tagref",
    sources = sources,
}
