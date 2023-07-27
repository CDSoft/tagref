#!/usr/bin/env luax

local check, list_refs, list_tags, list_unused

local function handle_args()
    local tagref = require "argparse"()
        :name "tagref"
        :description "Tagref helps you maintain cross-references in your code."
        :epilog "For more information, see https://github.com/CDSoft/tagref"
    tagref:option "-p"
        :description "Adds the path of a directory to scan"
        :target "path"
        :argname "path"
        :default "."
        :count "*"
    tagref:option "-r"
        :description "Sets the prefix used for locating references"
        :target "ref_prefix"
        :argname "ref-prefix"
        :default "ref"
    tagref:option "-t"
        :description "Sets the prefix used for locating tags"
        :target "tag_prefix"
        :argname "tag-prefix"
        :default "tag"
    tagref:require_command(false)
    tagref:command "check"
        :description "Checks all the tags and references (default)"
        :action(check)
    tagref:command "list-refs"
        :description "Lists all the references"
        :action(list_refs)
    tagref:command "list-tags"
        :description "Lists all the tags"
        :action(list_tags)
    tagref:command "list-unused"
        :description "Lists the unreferenced tags"
        :action(list_unused)
    -- default command
    check(tagref:parse())
end

local function scan(args)
    local F = require "F"
    local sh = require "sh"
    local fs = require "fs"

    local tags = F{}    -- [tag:tag_table]
    local refs = F{}    -- [tag:ref_table]

    local function add_tag(tagname, filename)
        local tag = tags[tagname] or {tagname=tagname, filenames=F{}, refs=F{}}
        tag.filenames[#tag.filenames+1] = filename
        tags[tagname] = tag -- update [ref:tag_table]
    end

    local function add_ref(refname, filename)
        local ref = refs[refname] or {refname=refname, filenames=F{}, tags=F{}}
        ref.filenames[#ref.filenames+1] = filename
        refs[refname] = ref -- update [ref:ref_table]
    end

    F(args.path):map(function(path)
        local git_files = sh.read{"git", "ls-files", path, "2>/dev/null"}
        local files = git_files and git_files:lines() or fs.walk(path)

        files:foreach(function(filename)
            if fs.is_file(filename) then
                local content, err = fs.read(filename)
                if content then
                    -- search for tags and update [ref:tag_table]
                    content:gsub("%["..args.tag_prefix..":([%w_]+)%]", function(tagname) add_tag(tagname, filename) end)
                    -- search for references and update [ref:ref_table]
                    content:gsub("%["..args.ref_prefix..":([%w_]+)%]", function(refname) add_ref(refname, filename) end)
                else
                    io.stderr:write("Error: ", filename, ": ", err, "\n")
                end
            end
        end)
    end)

    -- build links from references to tags and vice versa
    refs:foreacht(function(ref)
        local tag = tags[ref.refname]
        if tag then
            tag.refs[#tag.refs+1] = ref
            ref.tags[#ref.tags+1] = tag
        end
    end)

    return tags, refs
end

check = function(args)
    local tags, refs = scan(args)
    local ret = 0
    refs:values():foreach(function(ref)
        if #ref.tags == 0 then
            print(("%s:%s: dangling reference in %s"):format(args.ref_prefix, ref.refname, ref.filenames:str ", "))
            ret = 1
        end
    end)
    tags:values():foreach(function(tag)
        if #tag.filenames > 1 then
            print(("%s:%s: multiple definition in %s"):format(args.tag_prefix, tag.tagname, tag.filenames:str ", "))
            ret = 1
        end
    end)
    os.exit(ret)
end

list_refs = function(args)
    local _, refs = scan(args)
    refs:values():foreach(function(ref)
        print(("%s:%s: %s"):format(args.ref_prefix, ref.refname, ref.filenames:str ", "))
    end)
    os.exit()
end

list_tags = function(args)
    local tags, _ = scan(args)
    tags:values():foreach(function(tag)
        print(("%s:%s: %s"):format(args.tag_prefix, tag.tagname, tag.filenames:str ", "))
    end)
    os.exit()
end

list_unused = function(args)
    local tags, _ = scan(args)
    tags:values():foreach(function(tag)
        if tag.refs:null() then
            print(("%s:%s: %s"):format(args.tag_prefix, tag.tagname, tag.filenames:str ", "))
        end
    end)
    os.exit()
end

handle_args()
