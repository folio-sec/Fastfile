#!/usr/bin/env ruby

require 'uri'

puts 'START SCREENSHOTS PREVIE GENERATOR'

def createMarkdownEachDevice
  markdowns = {}
  Dir.glob('./FolioTests/ReferenceImages_*').each do |e|
    device = e[/ReferenceImages_((.*))/, 1]
    markdowns[device] = "# #{device}\n\n"

    Dir.glob(e + '/*').sort.each do |tests|
      vc = tests[/FolioTests\.((.*))/, 1]

      markdowns[device] += "## #{vc}\n\n"
      markdowns[device] += "|SCREENSHOT|SCREENSHOT|\n"
      markdowns[device] += "|:---:|:---:|\n"
      
      notFullscreen = Dir.glob(tests + '/*').select { |e| e.include?('_fullscreen') == false }
      withFullscreen = Dir.glob(tests + '/*').select { |e| e.include?('_fullscreen') }
      
      [notFullscreen, withFullscreen].each do |blob|
        blob.sort.each_slice(2) do |fileA, fileB|
          nameA = fileA ? fileA[/test([^!@]+)@/, 1].gsub('_', ' ') : ' '
          nameB = fileB ? fileB[/test([^!@]+)@/, 1].gsub('_', ' ') : ' '
          imgA = fileA ? "<img src='#{URI.encode(fileA)}' width='320' />" : ' '
          imgB = fileB ? "<img src='#{URI.encode(fileB)}' width='320' />" : ' '

          markdowns[device] += "|#{nameA}|#{nameB}|\n"
          markdowns[device] += "|#{imgA}|#{imgB}|\n"
        end
      end
      markdowns[device] += "\n\n"
    end
  end

  markdowns.keys.each do |key|
    File.write("screenshots_#{key}.md", markdowns[key])
  end
end

def createMarkdownEachTest
  FileUtils.mkdir_p('screenshots') unless FileTest.exist?('screenshots')

  markdowns = {}
  Dir.glob('./FolioTests/ReferenceImages_*').each do |e|
    device = e[/ReferenceImages_((.*))/, 1]   

    Dir.glob(e + '/*').sort.each do |tests|
      vc = tests[/FolioTests\.((.*))/, 1]
    
      markdowns[vc] = "## #{vc}\n\n" if markdowns[vc] == nil
      markdowns[vc] += "# #{device}\n\n"
      markdowns[vc] += "|SCREENSHOT|SCREENSHOT|\n"
      markdowns[vc] += "|:---:|:---:|\n"
      
      notFullscreen = Dir.glob(tests + '/*').select { |e| e.include?('_fullscreen') == false }
      withFullscreen = Dir.glob(tests + '/*').select { |e| e.include?('_fullscreen') }
      
      [notFullscreen, withFullscreen].each do |blob|
        blob.sort.each_slice(2) do |fileA, fileB|
          nameA = fileA ? fileA[/test([^!@]+)@/, 1].gsub('_', ' ') : ' '
          nameB = fileB ? fileB[/test([^!@]+)@/, 1].gsub('_', ' ') : ' '
          imgA = fileA ? "<img src='../#{URI.encode(fileA)}' width='320' />" : ' '
          imgB = fileB ? "<img src='../#{URI.encode(fileB)}' width='320' />" : ' '

          markdowns[vc] += "|#{nameA}|#{nameB}|\n"
          markdowns[vc] += "|#{imgA}|#{imgB}|\n"
        end
      end
      markdowns[vc] += "\n\n"
    end
  end

  markdowns.keys.each do |key|
    File.write("screenshots/screenshots_#{key}.md", markdowns[key])
  end  
end


createMarkdownEachDevice
createMarkdownEachTest