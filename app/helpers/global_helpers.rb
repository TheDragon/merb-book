module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  
    
    def same_url_but_in_english
      named_route = params[:chapter] ? :page : :toc
      url(named_route, :language => 'en', :chapter => params[:chapter], :page_name => params[:page_name])
    end
    
    def language_switch
      Merb::Plugins.config[:Merb_babel][:available_languages].map do |lang|
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
