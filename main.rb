#!/usr/bin/env ruby

#
# Requires
#

require "rubygems"
require "bundler"
require "erb"

Bundler.require(:default)

require_relative "lib/metadata"
require_relative "lib/templates"

#
# Constants
#

ROOT_DIR = Dir.pwd
META_DIR = File.join(ROOT_DIR, ".meta", "vector", "v0.10", ".meta")

#
# Setup
#

metadata = Metadata.load!(META_DIR, "/", "/", "/")
templates = Templates.new(ROOT_DIR, {})

templates.render("targets/vector/README.md")