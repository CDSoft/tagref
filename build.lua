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
https://codeberg.org/cdsoft/tagref
]]

version "0.2.4"

help.name "Tagref"
help.description "$name installation"

var "builddir" ".build"
clean "$builddir"

build.luax.add_global "flags" "-q"

local sources = { ls "src/*.lua" }

local tagref = build.luax.native "$builddir/tagref" { sources }

install "bin" { tagref }

default { tagref }

phony "release" {
    build.tar "$builddir/release/${version}/tagref-${version}-lua.tar.gz" {
        base = "$builddir/release/.build",
        name = "tagref-${version}-lua",
        build.luax.lua("$builddir/release/.build/tagref-${version}-lua/bin/tagref.lua") { sources },
    },
    require "targets" : map(function(target)
        return build.tar("$builddir/release/${version}/tagref-${version}-"..target.name..".tar.gz") {
            base = "$builddir/release/.build",
            name = "tagref-${version}-"..target.name,
            build.luax[target.name]("$builddir/release/.build/tagref-${version}-"..target.name/"bin/tagref") { sources },
        }
    end),
}

