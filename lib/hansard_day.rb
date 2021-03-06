require 'hpricot_additions'
require 'house'
require 'hansard_division'
require 'hansard_speech'

# Use this for sections of the Hansard that we're not currently supporting. Allows us to track
# title and subtitle.
class HansardUnsupported
  attr_reader :title, :subtitle
  
  def initialize(title, subtitle, day)
    @title, @subtitle, @day = title, subtitle, day
  end
  
  def permanent_url
    @day.permanent_url
  end
end

class HansardDay
  def initialize(page, logger = nil)
    @page, @logger = page, logger
    @house = nil
  end
  
  def house
    # Cache value
    unless @house
      @house = case @page.at('chamber').inner_html
        when "SENATE" then House.senate
        when "REPS" then House.representatives
        else throw "Unexpected value for contents of <chamber> tag"
      end
    end
    @house
  end
  
  def date
    # Cache value
    @date = Date.parse(@page.at('date').inner_html) unless @date
    @date
  end
  
  def permanent_url
    house_letter = house.representatives? ? "r" : "s"
    "http://parlinfo.aph.gov.au/parlInfo/search/display/display.w3p;query=Id:chamber/hansard#{house_letter}/#{date}/0000"
  end
  
  def in_proof?
    proof = @page.at('proof').inner_html
    @logger.error "#{date} #{house}: Unexpected value '#{proof}' inside tag <proof>" unless proof == "1" || proof == "0"
    proof == "1"
  end

  # Strip any HTML/XML tags from the given text and remove new-line characters
  def strip_tags(text)
    text.gsub(/<\/?[^>]*>/, "").gsub("\r", '').gsub("\n", '')
  end

  # Search for the title tag and return its value, stripping out any HTML tags
  def title_tag_value(debate)
    # Doing this rather than calling inner_text to preserve html entities which for some reason get all screwed up by inner_text
    strip_tags(debate.search('> * > title').map{|e| e.inner_html}.join('; '))
  end
  
  def title(debate)
    case debate.name
    when 'debate', 'petition.group'
      title = title_tag_value(debate)
      cognates = debate.search('> debateinfo > cognate > cognateinfo > title').map{|a| strip_tags(a.inner_html)}
      ([title] + cognates).join('; ')
    when 'subdebate.1', 'subdebate.2', 'subdebate.3', 'subdebate.4'
      title(debate.parent)
    else
      throw "Unexpected tag #{debate.name}"
    end
  end
  
  def subtitle(debate)
    case debate.name
    when 'debate', 'petition.group'
      ""
    when 'subdebate.1'
      title_tag_value(debate)
    when 'subdebate.2', 'subdebate.3', 'subdebate.4'
      subtitle(debate.parent) + '; ' + title_tag_value(debate)
    else
      throw "Unexpected tag #{debate.name}"
    end    
  end
  
  def time(debate)
    # HACK: Hmmm.. check this out more 
    tag = debate.at('(time.stamp)')
    tag.inner_html if tag
  end      
  
  def pages_from_debate(debate)
    p = []
    title = title(debate)
    subtitle = subtitle(debate)
    
    question = false
    procedural = false
    debate.each_child_node do |e|
      case e.name
      when 'debateinfo', 'subdebateinfo', 'petition.groupinfo'
        question = false
        procedural = false
      when 'speech'
        p << e.map_child_node {|c| HansardSpeech.new(c, title, subtitle, time(e), self, @logger)}
        question = false
        procedural = false
      when 'division'
        #puts "SKIP: #{e.name} > #{full_title}"
        p << HansardDivision.new(e, title, subtitle, self)
        question = false
        procedural = false
      when 'petition'
        #puts "SKIP: #{e.name} > #{full_title}"
        p << HansardUnsupported.new(title, subtitle, self)
        question = false
        procedural = false
      when 'question', 'answer'
        # We'll skip answer because they always come in pairs of 'question' and 'answer'
        unless question
          questions = []
          f = e
          while f && (f.name == 'question' || f.name == 'answer') do
            questions = questions + f.map_child_node {|c| HansardSpeech.new(c, title, subtitle, time(e), self, @logger)} 
            f = f.next_sibling
          end
          p << questions
        end
        question = true
        procedural = false
      when 'motionnospeech', 'para', 'motion', 'interjection', 'quote', 'list', 'interrupt', 'amendments', 'table', 'separator', 'continue'
        procedural_tags = %w{motionnospeech para motion interjection quote list interrupt amendments table separator continue}
        unless procedural
          procedurals = []
          f = e
          while f && procedural_tags.include?(f.name) do
            procedurals << HansardSpeech.new(f, title, subtitle, time(f), self, @logger)
            f = f.next_sibling
          end
          p << procedurals
        end
        question = false
        procedural = true
      when 'subdebate.1', 'subdebate.2', 'subdebate.3', 'subdebate.4'
        p = p + pages_from_debate(e)
        question = false
        procedural = false
      else
        throw "Unexpected tag #{e.name}"
      end
    end
    p
  end
  
  def pages
    p = []
    # Step through the top-level debates
    # When something that was a page in old parlinfo web system is not supported we just return nil for it. This ensures that it is
    # still accounted for in the counting of the ids but we don't try to use it to generate any content
    p << nil
    @page.at('hansard').each_child_node do |e|
      case e.name
      when 'session.header'
      when 'chamber.xscript', 'maincomm.xscript'
        e.each_child_node do |e|
          case e.name
            when 'business.start', 'adjournment', 'interrupt', 'interjection'
              p << nil
            when 'debate', 'petition.group'
              p = p + pages_from_debate(e)
            else
              throw "Unexpected tag #{e.name}"
          end
        end
      when 'answers.to.questions'
        e.each_child_node do |e|
          case e.name
          when 'debate'
          else
            throw "Unexpected tag #{e.name}"
          end
        end
      else
        throw "Unexpected tag #{e.name}"
      end
    end
    p
  end  
end