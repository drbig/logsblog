require 'coderay_bash'
include Nanoc3::Helpers::Blogging

class HTMLKillerFilter < Nanoc::Filter
  identifier :html_killer
  type :text

  def run(content, params = {})
    content.gsub(/\<.*?\>/, '')
  end
end

class SectionLinkerFilter < Nanoc::Filter
  identifier :section_linker
  type :text

  def run(content, params = {})
    content.gsub(/\<(h\d) id="(.*?)".*?\>/,\
    	'<\1 id="\2"><a class="section" href="#\2">&sect;</a> ')
  end
end

class ImageResamplerFilter < Nanoc::Filter
  identifier :image_resampler
  type :binary

  def run(filename, params = {})
    system('convert', '-resize', "#{params[:width]}x#{params[:width]}>",\
    	filename, output_filename)
  end
end

class SourceInserterFilter < Nanoc::Filter
  identifier :source_inserter
  type :text

  def run(content, params = {})
    ncontent = ''

    content.each_line do |line|
      if m = line.match(/^\[src:(.*?)(:lang=.*?)?(:lines=.*?)?\]/)
        opts = { :lines => false, :lang => false }
        path, *nopts = m.captures

        nopts.each do |o|
          next if o.nil?
        
          cmd, arg = o.match(/:(.*?)=(.*)/).captures
        
          case cmd
          when 'lang'
            opts[:lang] = arg
          when 'lines'
            lines = arg.split(',').collect{|e| e.to_i}
            lines[1] -= lines[0] - 1
            lines[0] -= 1
            opts[:lines] = lines
          end
        end

        data = File.read(path)
        data = data.lines.to_a.slice(*opts[:lines]).join if opts[:lines]

        if @item_rep.name == :text
          ncontent += "--------- CODE BEGIN ---------\n" 
          ncontent += data
          ncontent += "--------- CODE END -----------\n" 
        else
          if opts[:lang]
            ncontent += "{:lang='#{opts[:lang]}'}\n"
          else
            ncontent += "\n"
          end
          data.each_line{|l| ncontent += '    ' + l}
        end
      else
        ncontent += line
      end
    end
    
    ncontent
  end
end
