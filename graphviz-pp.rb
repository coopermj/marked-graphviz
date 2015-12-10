#!/usr/bin/env ruby
# Pre-processor for Marked2.app
# Takes markdown and spits out any graphviz diagrams into
# tagged files and rewrites markdown to reference those files
# Created by Micah Cooper based on the work of Brett Terpstra
# Version 1.2

require 'rubygems'
require 'nokogiri'
require 'open3'
include Open3

customStyle = 1
css = nil
csstext = nil

# Create a cachebuster
r = Random.new
r.rand(100000)

# set our current directory to the doc's directory
if (ENV['MARKED_ORIGIN'])
	Dir.chdir(ENV['MARKED_ORIGIN'])
end

def customStyler(name)
	if (ENV['MARKED_CSS_PATH'])
		css = File.open(ENV['MARKED_CSS_PATH']) { |f| Nokogiri::HTML(f) }

		# Open the svg we just created
		svg = File.open(name) { |f| Nokogiri::XML(f) }
		# Strip out the default font-family and size
		# I couldn't find a way to suppress the creation and we need to open the file for
		# modification anyway
		svg.xpath('//@font-family').remove
		svg.xpath('//@font-size').remove

		# Create our defs/style structure and layer it in
		defs_node = Nokogiri::XML::Node.new("defs", svg)
		style_node = Nokogiri::XML::Node.new("style", svg)
		style_node['type'] = "text/css"

		cdata = "![CDATA[\n" << css.inner_text << "\n]]"		
		style_node.add_child(cdata)

		defs_node << style_node
		svg.root << defs_node  

		# Save our changes
		File.write(name, svg.to_xml)
	end
end

# Get content from STDIN
content = STDIN.read

# capture content into parsing system
html_doc = Nokogiri::HTML(content)


#find all the <dot> references
#puts html_doc.xpath("//dot")
allDots = html_doc.xpath("//dot")
allDots.each do |dot|
	dotString = dot.text
	# use whatever is before the { for naming
	basename = dotString.match(/(.*){/).to_s
	#puts basename
	caption = dotString.match(/graph (.*)(\s*){/)[1]
	caption = caption.rstrip
	caption.gsub!(/_/, ' ')
	#....need to 
	#caption = fullcaption[1]


	# remove all the whitespace and non-characters
	name = basename.gsub!(/\W+/, '') << ".svg"

	# set our options and command line
	runstring = "dot -Tsvg -o #{name}"

	# shell out to the command line and run the above command
	output = Open3.capture2(runstring, :stdin_data=>dotString)

	# Add a new entry in markdown to reference the file we just created
	dot.add_next_sibling("![#{caption}](#{name}?#{r})")

	# remove the <dot> entry from the html
	dot.remove
	
	# customStyle lets us pull in a specific css file to append to our svg
	# since passing along styling through graphviz can be a pain (and non-modern)
	if (1 == customStyle)
		customStyler(name)
	end
end

#find all the <neato> references
allNeats = html_doc.xpath("//neato")
allNeats.each do |neat|
	neatString = neat.text
	# use whatever is before the { for naming
	basename = neatString.match(/(.*){/).to_s
	#puts basename
	caption = neatString.match(/graph (.*)(\s*){/)[1]
	caption = caption.rstrip
	caption.gsub!(/_/, ' ')

	# remove all the whitespace and non-characters
	name = basename.gsub!(/\W+/, '') << ".svg"

	# set our options and command line
	runstring = "neato -Tsvg -o #{name}"

	# shell out to the command line and run the above command
	output = Open3.capture2(runstring, :stdin_data=>neatString)

	# Add a new entry in markdown to reference the file we just created
	neat.add_next_sibling("![#{caption}](#{name}?#{r})")

	# remove the <neato> entry from the html
	neat.remove
	
	# customStyle lets us pull in a specific css file to append to our svg
	# since passing along styling through graphviz can be a pain (and non-modern)
	if (1 == customStyle)
		customStyler(name)
	end
end


# return just the text (not html) to STDOUT for Marked to process
puts html_doc.inner_text

