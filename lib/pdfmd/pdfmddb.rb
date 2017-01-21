# == Class: pdfmd::db
#
class Pdfmddb 

  attr_accessor :dbfilename, :db
  require 'sqlite3'
  require 'sequel'
  require 'digest/md5'

  # Array with document paths to to search for documents.
  @document_path = Array.new

  def initialize(dbfilename)
    @dbfilename = dbfilename
    @db_update_data = Hash.new
  end

  # Create the database file
  def create

    if File.exists?(dbfilename)
      puts "Moved '#{dbfilename}' to '#{dbfilename}.bak'."
      FileUtils.mv(dbfilename, dbfilename + '.bak')
    end
    db = Sequel.sqlite(dbfilename)
    db.create_table :pdfmd_documents do
      String :md5sum, :primary_key => true
      String :filename
      String :author
      String :title
      String :subject
      Date :createdate
      String :keywords
      String :filepath
    end
    db.add_index :pdfmd_documents, :md5sum
    db.add_index :pdfmd_documents, :keywords
  end

  # Setting and reading the document path for the update
  def self.document_path
    @document_path
  end

  def document_path
    self.class.document_path
  end

  # update the database
  def run_update
    puts 'running the update on ' + self.document_path.to_s
    self.document_path.each do |array_path|
      Dir.glob(array_path + '/*/**').grep(/\.pdf$/i).each do |current_file|

        md5sum = Digest::MD5.hexdigest(File.open(current_file, 'rb'){ |f| f.read})
        @db_update_data[md5sum] = { :filepath => current_file } 

        # Read all Tags from a file
        pdfdoc = Pdfmdshow.new 
        pdfdoc.set_file current_file
        options = {
          :format     => 'hash',
          :includepdf => true
        }
        @db_update_data[md5sum].merge!(transform_keys_to_symbols(pdfdoc.show_metatags options))

      end

    end

    self.update_db
    puts 'Database updated.'

  end

  # Update the Database
  # Existing enstries will be updated.
  def update_db

    db = Sequel.sqlite(dbfilename)
    @db_update_data.each do |key,value|
      md5sum = {:md5sum => key}
      file_tupel = md5sum.merge(value)
      db[:pdfmd_documents].insert_conflict(:replace).insert(file_tupel)
    end

  end

  # Snippet to tranform keys to symboles
  # source: http://www.any-where.de/blog/ruby-hash-convert-string-keys-to-symbols/
  # This is very useful!
  def transform_keys_to_symbols(value)
    if value.is_a?(Array)
      array = value.map{|x| x.is_a?(Hash) || x.is_a?(Array) ? transform_keys_to_symbols(x) : x}
      return array
    end
    if value.is_a?(Hash)
      hash = value.inject({}){|memo,(k,v)| memo[k.to_sym] = transform_keys_to_symbols(v); memo}
      return hash
    end
    return value
  end

  # Small statistics output
  def statistics

    db = Sequel.sqlite(dbfilename)
    'Documents: ' + db[:pdfmd_documents].count(:md5sum).to_s 

  end

  # Search the database in the keyword field
  def search(search_terms)

    db = Sequel.sqlite(dbfilename)
    dataset = db[:pdfmd_documents].where("UPPER(keywords) LIKE UPPER('%#{search_terms[0]}%')")
    result_files = ''
    dataset.all.each do |match_file|
      match_file.each do |key,value|
        if key == :keywords

          # Split the keywords
          keywords = value.downcase.split(/\s*,\s*/)
          # Search for matches in the keywords.
          if keywords.find{ |e| /#{search_terms.join(' ').downcase}/ =~ e }
            result_files += match_file[:filename] + "\n"
          end
        end

      end
    end

    # Ouput result filenames
    result_files

  end
end
