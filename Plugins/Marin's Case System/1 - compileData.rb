module Evidence
  @@compiledData = nil
  @@reloaded = false

  EvidenceSchema = {
    "Name" => [:Name, "*s"],
    "Case" => [:Case, "*i"],
    "Use"  => [:Use, "*s"],
    "Description" => [:Description, "*s"],
    "Testimony" => [:Testimony, "b"]
  }

  #-------------------------------------------------------------------------#
  #                 Compile Functions                                       #
  #-------------------------------------------------------------------------#
  def self.compile(mustCompile = false)
    return if !$DEBUG or not safeIsDirectory?("PBS")
    if !safeExists?("PBS/evidence.txt")
      self.generatePBS()
    end

    pbSetWindowText("Compiling Evidence data...")
    refresh = mustCompile
    refresh = true if !safeExists?("Data/evidence.dat")
    refresh = true if Input.press?(Input::CTRL)
    refresh = true if !refresh and safeExists?("PBS/evidence.txt") and
      File.mtime("PBS/evidence.txt") > File.mtime("Data/evidence.dat")
    if refresh
      Compiler.compile_pbs_file_message_start("PBS/evidence.txt")
      data = self.compile_evidence()
      if not data
        raise _INTL("Compilation of Evidence data failed, evidence.txt may not exist or PBS may not exist.")
      end
      save_data(data, "Data/evidence.dat")
      Compiler.process_pbs_file_message_end
      @@compiledThisLaunch = true
    end
    pbSetWindowText(nil)
  end

  def self.recompile()
    write_evidence()
    puts "\nUpdating Data/evidence.dat..."
    data = compile_evidence()
    save_data(data, "Data/evidence.dat") if data != nil
    if data == nil
      puts "Compiling Failed, somehow couldn't find the file that was written to."
      return
    end
    puts "Compiling of new evidence.dat successful.\n" if data != nil
    puts "Reloading compiled data..."
    ensureCompiledData(true)
    puts "Compiled Data reloaded."
  end

  def self.seperateCommaValues(str, type)
    outputs = [""]
    pos = 0
    inQuotes = false
    str.scan(/./) do |c|
      case c
      when "\""
        inQuotes = (not inQuotes)
      when " "
        outputs[pos] += c if type == "s"
      when ","
        if not inQuotes
          outputs.push("")
          pos += 1
        else
          outputs[pos] += c
        end
      else
        outputs[pos] += c
      end
    end
    outputs.each{ |element|
      Compiler::prepline(element)
    }
    return outputs
  end

  def self.mapFromSchema(hash, value, schema, lineNo)
    return if !schema
    multi = false
    type = nil
    seperatedValues = nil
    if schema[1].length > 1
      multi = true
      type = schema[1][1]
    else
      type = schema[1]
    end
    seperatedValues = seperateCommaValues(value, type) if multi
    case type
    when "s"
      if not seperatedValues
        value.gsub!(/"/, "") # remove quotes if the there is only one string
        hash[schema[0]] = value
      else
        hash[schema[0]] = seperatedValues
      end
    when "b"
      if value[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Yy]$/]
        hash[schema[0]] = true
      elsif value[/^0|[Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]|[Nn]$/]
        hash[schema[0]] = false
      else
        raise _INTL("Field #{schema[0]} at line #{lineNo} within evidence.txt is not a Boolean value, please provide true, yes, y, or 1 for true or false, no, n, or 0 for false values.\r\n")
      end
    when "i"
      if seperatedValues
        hash[schema[0]] = []
        for i in seperatedValues
          if !i[/^\-?\d+$/]
            raise _INTL("Field #{schema[0]} at line #{lineNo} within evidence.txt is not an Integer value")
          end
          hash[schema[0]].push(i.to_i)
        end
      else
        if !value[/^\-?\d+$/]
          raise _INTL("Field #{schema[0]} at line #{lineNo} within evidence.txt is not an Integer value")
        end
        hash[schema[0]] = (value.to_i)
      end
    when "u"
      if seperatedValues
        hash[schema[0]] = []
        for u in seperatedValues
          if !u[/^\d+$/]
            raise _INTL("Field #{schema[0]} at line #{lineNo} within evidence.txt is not a positive Integer value")
          end
          hash[schema[0]].push(u.to_i)
        end
      else
        if !value[/^\d+$/]
          raise _INTL("Field #{schema[0]} at line #{lineNo} within evidence.txt is not a positive Integer value")
        end
        hash[schema[0]] = (value.to_i)
      end
    end
  end

  def self.ensureRequiredData(data, currentEvidence)
     # Deal with Arrays and Numeric values
    data[currentEvidence][:Name] = currentEvidence.to_s if not data[currentEvidence][:Name]
    data[currentEvidence][:Name] = data[currentEvidence][:Name].join(",") if data[currentEvidence][:Name].is_a?(Array)
    raise _INTL("No icon found at Graphics/Evidence/Icons/'#{currentEvidence}'.\n") if !File.file?("Graphics/Evidence/Icons/" + currentEvidence.to_s.downcase + ".png")
    data[currentEvidence][:Case] = [1,2,3] if not data[currentEvidence][:Case]
    data[currentEvidence][:Case] = [data[currentEvidence][:Case]] if data[currentEvidence][:Case].is_a?(Numeric)
    data[currentEvidence][:Use] = ["No use given..."] if not data[currentEvidence][:Use]
    data[currentEvidence][:Use] = data[currentEvidence][:Use].join(",") if data[currentEvidence][:Use].is_a?(Array)
    data[currentEvidence][:Description] = ["No description given..."] if not data[currentEvidence][:Description]
    data[currentEvidence][:Description] = data[currentEvidence][:Description].join(", ") if data[currentEvidence][:Description].is_a?(Array)
    data[currentEvidence][:Testimony] = false if not data[currentEvidence][:Testimony]
    raise _INTL("No clue image found at Graphics/Evidence/Clues/'#{currentEvidence}'.\n") if data[currentEvidence][:Testimony] == false && 
    !File.file?("Graphics/Evidence/Clues/" + currentEvidence.to_s.downcase + ".png")
  end

  def self.compile_evidence()
    return nil if !safeExists?("PBS/evidence.txt")
    data = {}
    currentEvidence = nil
    lineNo = -1
    File.open("PBS/evidence.txt") do |file|
      line = ""
      while line != nil
        line = Compiler::prepline(line)
        if line[/^#*$/]
          lineNo += 1
          line = file.gets()
          next
        end

        m = line.match(/^\s*\[\s*(.+)\s*\]$/)
        if m
          self.ensureRequiredData(data, currentEvidence) if currentEvidence
          raise _INTL("#{m[1].to_sym} already exists, having multiple entries will cause major problems") if data[m[1].to_sym] != nil
          data[m[1].to_sym] = {}
          currentEvidence = m[1].to_sym
        end
        m = line.match(/^\s*(\w+)\s*=\s*(.*)\s*$/)
        if m
          raise _INTL("First non commented line of evidence.txt was not a [], Data will be unusable") if currentEvidence == nil
          self.mapFromSchema(data[currentEvidence], m[2], EvidenceSchema[m[1]], lineNo)
        end
        lineNo += 1
        line = file.gets()
      end
      self.ensureRequiredData(data, currentEvidence)
    end
    return data
  end

  def self.generateDefaultData()
    return {
      :TESTDAY => {
        :Name => "Palermo's Testimony",
        :Case => 1,
        :Use => "Introducing yourself to Palermo.",
        :Description => "The waitress was handed the cheque during the ceremony.",
        :Testimony => true
      }
    }  
  end

  def self.generatePBS()
    puts "evidence.txt doesn't exist within PBS, generating a new one...\n"
    @@compiledData = safeExists?("Data/evidence.dat") ? load_data("Data/evidence.dat") : self.generateDefaultData()
    self.write_evidence()
    @@compiledData = nil
    puts "new evidence.txt successfully generated\n"
  end

  def self.ensureCompiledData(overwrite = false)
    return if @@reloaded == true and overwrite == false
    @@compiledData = load_data("Data/evidence.dat") rescue {}
    @@reloaded = true
  end

  def self.compiledData()
    if @@compiledData == nil
      self.ensureCompiledData()
    end
    return @@compiledData
  end
  #-------------------------------------------------------------------------#
  #                 Write Functions                                         #
  #-------------------------------------------------------------------------#
  def self.writeEvidenceHeader(file)
    file.write("#-------------------------------------------------\n")
    file.write("# Evidence Definition:\n")
    file.write("# This evidence has a very simple format, which is as follows:  \n")
    file.write("# [INTERNALNAME], must be unique\n")
    file.write("# Name = Display Name\n")
    file.write("# Case = Num1, Num2, Num3 \n")
    file.write("# Use = Short usage text  \n")
    file.write("# Description = A longer description that says what the evidence is for.\n")
    file.write("# (Testimony = true) \n")
    file.write("#\n")
    file.write("#-------------------------------------------------\n")
  end

  def self.writeBySchema(file, value, schema, tab = false)
    multi = schema[1][0] == "*" ? true : false
    type = schema[1][multi ? 1 : 0]
    tab = tab ? "\t" : ""
    file.write("#{tab}#{schema[0].to_s}=")
    case type
    when "b"
      file.write("#{value}\n")
    when "i"
      if not multi
        file.write("#{value}\n")
      else
        size = value.length
        for i in 0...size
          file.write("#{value[i]}")
          file.write(",") if i != size - 1
          file.write("\n") if i == size - 1
        end
      end
    when "s"
      if not multi
        file.write("#{value}\n")
      else
        size = value.length
        for i in 0...size
          file.write("\"#{value[i]}\"")
          file.write(",") if i != size - 1
          file.write("\n") if i == size - 1
        end
      end
    when "u"
      if not multi
        file.write("#{value}\n")
      else
        size = value.length
        for i in 0...size
          file.write("#{value[i]}")
          file.write(",") if i != size - 1
          file.write("\n") if i == size - 1
        end
      end
    else
      file.write("\n")
    end
  end

  def self.write_evidence()
    return if @@compiledData == nil
    puts "Begin writing evidence.txt within PBS.."
    filePath = "PBS/evidence.txt"
    File.open("#{filePath}", "w"){ |file|
      writeEvidenceHeader(file)
      @@compiledData.each{ |key, val|
        file.write("[#{key.to_s}]\n")
        val.each{ |k, v|
          next if not EvidenceSchema[k.to_s]
          schem = EvidenceSchema[k.to_s]
          writeBySchema(file, v, schem)
        }
        file.write("#------------------------------------------\n")
      }
    }
    puts "\nFile successfully written to."
  end
end

module Compiler
  class << Compiler
    alias compile_all_case_system compile_all
  end

  def self.compile_all(mustCompile)
    compile_all_case_system(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
    Evidence.compile()
  end
end