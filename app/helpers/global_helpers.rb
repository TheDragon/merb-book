module Merb
  module GlobalHelpers
    # helpers defined here available to all views.

    def same_url_but_in_english
      named_route = params[:chapter] ? :page : :toc
      url(named_route, :language => 'en', :chapter => params[:chapter], :page_name => params[:page_name])
    end

    def language_switch
      Merb::Plugins.config[:Merb_babel][:available_languages].map do |lang|
        href = "/#{lang[:code]}"
        href += "/#{params[:chapter]}" if params[:chapter]
        href += "/#{params[:page_name]}" if params[:page_name]
        "<a href='#{href}'>#{lang[:name]}</a>" unless lang[:code] == language
      end.compact.join(" | ")
    end
    
        link_to lang[:name], lang[:code] unless lang[:code] == language
      end.compact.join(" | ")
    end
    
    # friendly chapter navigation
    def turn_page(direction,format='markdown')
      case direction
      when 'fwd'
        if params[:chapter]
          tree = "<div class='tree'><div class='tree_chapter'><a href='#{url(:page, params[:language], params[:chapter])}'>#{params[:chapter]}</a></div>"
          pages_tree = pages_in_chapter(params[:chapter]).each do |branch|
            unless branch == params[:page_name]
              tree += "<div class='tree_page'><a href='#{url(:page, params[:language], params[:chapter], branch)}'>#{branch}</a></div>"
            else
              tree += "<div class='tree_page'>#{branch}</div>"
            end
          end
          tree += '</div>'
          tree
        end
      when 'back'
        # backward
      end
    end
    
    # Returns links to the previous and next pages.
    def page_nav_links(format = 'markdown')
      return unless params[:action] == 'show' # Don't need navigation for the TOC (index).
      links = []
      chapter = params[:chapter]
      page_name = params[:page_name]
      current_file = Dir["#{Merb.root}/book-content/#{language}/*-#{chapter}/*-#{page_name||"*"}.#{format}"].entries.first
      if current_file
        current_file.grep(/book-content\/\w{2}\/(\d{1,})-[a-z-]+\/(\d{1,})-[a-z-]+[.]\w+/)
        chapter_number, page_number = $1, $2
      end

      chapter_name, page_name = extract_previous_page(chapter_number, page_number)
      links << previous_page(chapter_name, page_name)

      # Stick a link to the TOC in the middle of the array.
      links << link_to('Home', url(:toc, :language => language))

      chapter_name, page_name = extract_next_page(chapter_number, page_number)
      links << next_page(chapter_name, page_name)

      links.join(' | ')
    end

    private

    def next_page(chapter_name, page_name)
      link_to('Next', url(:page, :language => language, :chapter => chapter_name, :page_name => page_name))
    end

    def previous_page(chapter_name, page_name)
      link_to('Previous', url(:page, :language => language, :chapter => chapter_name, :page_name => page_name))
    end

    # This method returns a Regexp which contains match captures for the chapter and page names.
    def chapter_and_page_names
      /book-content\/\w{2}\/\d{1,}-([a-z-]+)\/\d{1,}-([a-z-]+)[.]\w+/
    end

    # Returns an array of the next chapter and page names.
    def extract_next_page(chapter_number, page_number, format = 'markdown')
      next_file = Dir["#{Merb.root}/book-content/#{language}/#{chapter_number}-*/#{page_number.to_i + 1}-*.#{format}"].entries.first
      if next_file
        next_file.grep(chapter_and_page_names)
      else
        # We're on the last page, get the first page of the next chapter.
        next_file = Dir["#{Merb.root}/book-content/#{language}/#{chapter_number.to_i + 1}-*/**"].entries.first
        if next_file
          next_file.grep(chapter_and_page_names)
        else
          # We're on the last page of the last chapter, just return the TOC.
          return 'table-of-contents'
        end
      end
      chapter_name, page_name = $1, $2
      [chapter_name, page_name]
    end

    # Returns an array of the previous chapter and page names.
    def extract_previous_page(chapter_number, page_number, format = 'markdown')
      next_file = Dir["#{Merb.root}/book-content/#{language}/#{chapter_number}-*/#{page_number.to_i - 1}-*.#{format}"].entries.first
      if next_file
        next_file.grep(chapter_and_page_names)
      else
        # We're on the first page, get the last page of the previous chapter.
        next_file = Dir["#{Merb.root}/book-content/#{language}/#{chapter_number.to_i - 1}-*/**"].entries.last
        if next_file
          next_file.grep(chapter_and_page_names)
        else
          # We're on the first page of the first chapter, just return the TOC.
          return 'table-of-contents'
        end
      end
      chapter_name, page_name = $1, $2
      [chapter_name, page_name]
    end
    
    # friendly chapter navigation

    
    private
    
    def forward
      debugger
      chapters = all_chapters
      chapter = params[:chapter] || chapters.first
      pages = pages_in_chapter(chapter)
      page_name = params[:page_name] || pages.first
      unless chapters.last == chapter && pages.last == page_name
        if pages.last == page_name
          chapter_index = chapters.rindex(chapter).next
          next_chapter = chapters[chapter_index]
          next_page = pages_in_chapter(next_chapter).first
        else
          next_chapter = chapter
          page_index = pages.rindex(page_name).next
          next_page = pages[page_index]
        end
        next_section = {:next_page => next_page, :next_chapter => next_chapter}
      else
        next_section = "THE END"
      end
    end
    
    def all_chapters(format='markdown')
      chapter_index = []
      chapter_path = Dir["#{Merb.root}/book-content/#{language}/*"].entries
      chapter_path.each do |page|
        next if page =~ /#{format}$/
        chapter_index << /\d{1,}[-]([\w+|-]*)/.match(page)[1]
      end
      chapter_index
    end
    
    def pages_in_chapter(chapter,format='markdown')
      page_index = []
      pages_path = Dir["#{Merb.root}/book-content/#{language}/*-#{chapter}/*"].entries
      pages_path.each do |page|
        page_index << /\d{1,}[-]([\w+|-]*)\.#{format}$/.match(page)[1]
      end
      page_index
    end
  end
end
