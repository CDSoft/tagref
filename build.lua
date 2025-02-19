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

local sh = require "sh"

help.name "Tagref"
help.description "$name installation"

var "builddir" ".build"
clean "$builddir"

var "git_version" { sh "git describe --tags" }
generator { implicit_in = ".git/refs/tags" }

build.luax.add_global "flags" "-q"

local sources = { ls "src/*.lua" }

local tagref = build.luax.native "$builddir/tagref" { sources }

install "bin" { tagref }

default { tagref }

phony "release" {
    build.tar "$builddir/release/${git_version}/tagref-${git_version}-lua.tar.gz" {
        base = "$builddir/release/.build",
        name = "tagref-${git_version}-lua",
        build.luax.lua("$builddir/release/.build/tagref-${git_version}-lua/bin/tagref.lua") { sources },
    },
    require "targets" : map(function(target)
        return build.tar("$builddir/release/${git_version}/tagref-${git_version}-"..target.name..".tar.gz") {
            base = "$builddir/release/.build",
            name = "tagref-${git_version}-"..target.name,
            build.luax[target.name]("$builddir/release/.build/tagref-${git_version}-"..target.name/"bin/tagref") { sources },
        }
    end),
}

