require 'terrier'
require 'fileutils'

resolved_dois = Hash.new

base_name = ARGV[0]

FileUtils.touch(base_name + ".resolved")
File.open(base_name+".resolved", "r") do |f|
  f.each_line do |line|
    la = line.strip.split("\t")
    resolved_dois[la[0]] = 1
  end
end

puts resolved_dois

begin
  file = File.open(base_name + ".resolved", "a")

  File.open(base_name, "r") do |f|
    f.each_line do |line|
      unless resolved_dois.key?(line.strip)
        begin
          doi_result = Terrier.new(line.strip)
          doi = line.strip
          journal = doi_result.citation_data[:journal]
          published = doi_result.citation_data[:publication_year].to_s
          publisher = doi_result.citation_data[:publisher]
          puts doi + "\t" + journal + "\t" + published + "\t" + publisher
          file.write(doi + "\t" + journal + "\t" + published + "\t" + publisher +  "\n")
        rescue
          puts "DOI error"
          file.write(line.strip + "\terror resolving\n")
        end
      end
    end
  end

rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file.nil?
end
