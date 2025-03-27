require_relative './Data/Scripts/001_Technical/005_PluginManager.rb'
module PluginManager
    RUN_DECOMPILED = true
    class << self
        alias_method :runPlugins_original, :runPlugins
        alias_method :listAll_original, :listAll
    end

    def self.listAll
        if RUN_DECOMPILED
            dirs = []
            Dir.get("Plugins").each { |d| dirs.push(d) if Dir.safe?(d) }
            # return all plugins
            return dirs
        else
            return _listAll_original
        end
    end
    
    def self.runPlugins
        if RUN_DECOMPILED
            # get the order of plugins to interpret
            order, plugins = self.getPluginOrder
            scripts = self.getPlugins(order, plugins)
            # # compile if necessary
            # self.compilePlugins(order, plugins) if self.needCompiling?(order, plugins)
            # load plugins
            echoed_plugins = []
            for plugin in scripts
                # get the required data
                name, meta, script = plugin
                if (name === "Consistent AI")
                    print("Original Consistent AI")
                elsif (name === "Edited Consistent AI")
                    print("Edited Consistent AI")
                end
                # register plugin
                self.register(meta)
                # go through each script and interpret
                for scr in script
                    # turn code into plaintext
                    code = Zlib::Inflate.inflate(scr[1]).force_encoding(Encoding::UTF_8)
                    # get rid of tabs
                    code.gsub!("\t", "  ")
                    # construct filename
                    sname = scr[0].gsub("\\","/").split("/")[-1]
                    fname = "[#{name}] #{sname}"
                    # try to run the code
                    begin
                        eval(code, TOPLEVEL_BINDING, fname)
                        echoln "Loaded plugin: #{name}" if !echoed_plugins.include?(name)
                        echoed_plugins.push(name)
                    rescue Exception   # format error message to display
                        self.pluginErrorMsg(name, sname)
                        Kernel.exit! true
                    end
                end
            end
            echoln '' if !echoed_plugins.empty?
        else
            _runPlugins_original
        end
    end

    def self.decompilePlugins
        # get the order of plugins to interpret
        # load plugins
        scripts = load_data("Data/PluginScripts.rxdata")
        echoed_plugins = []
        plugins_meta = []
        # print(File.expand_path("./Plugins_decompiled",Dir.pwd))
        plugins_dir = File.expand_path("./Plugins",Dir.pwd)
        if !Dir.exist?(plugins_dir)
            Dir.mkdir(plugins_dir)
        end

        # test = File.expand_path("./Plugins/test.txt",Dir.pwd)
        # File.open(test, 'ab') do |f|
        #   f.write("hello, world")
        # end
        for plugin in scripts
        # get the required data
        name, meta, script = plugin
        c_name = self.cleanDirName(name)
        plugin_dir = File.expand_path("./Plugins/#{c_name}",Dir.pwd)
        if !Dir.exist?(plugin_dir) 
            Dir.mkdir(plugin_dir)
        end

        meta_file = File.expand_path("./Plugins/#{c_name}/meta.txt",Dir.pwd)
        File.open(meta_file, 'wb') do |f|
            f.write(self.createMeta(meta))
        end
        # register plugin
        self.register(meta)
        plugins_meta.push(meta)
        # go through each script and interpret
        for scr in script
            # turn code into plaintext
            code = Zlib::Inflate.inflate(scr[1]).force_encoding(Encoding::UTF_8)
            # get rid of twbs
            code.gsub!("\t", "  ")
            # construct filename
            sname = scr[0].gsub("\\","/").split("/")[-1]
            fname = "[#{c_name}] #{sname}"
            
            script_dir = File.expand_path("./Plugins/#{c_name}/#{sname}",Dir.pwd)
            File.open(script_dir, 'wb') do |f|
            f.write(code)
            end
            # print("#{fname}:\r\n")
            # print("#{fname}:\r\n #{code}\r\n")
            # print(Dir.pwd)
        end
        end
        print("Plugins decompiled successfully.\r\n")
    end

    def self.getPlugins(order, plugins)
        echo 'Compiling plugin scripts...'
        scripts = []
        # go through the entire order one by one
        for o in order
        # save name, metadata and scripts array
        meta = plugins[o].clone
        meta.delete(:scripts)
        meta.delete(:dir)
        dat = [o, meta, []]
        # iterate through each file to deflate
        for file in plugins[o][:scripts]
            File.open("#{plugins[o][:dir]}/#{file}", 'rb') do |f|
            dat[2].push([file, Zlib::Deflate.deflate(f.read)])
            end
        end
        # push to the main scripts array
        scripts.push(dat)
        end
        # save to main `PluginScripts.rxdata` file
        # collect garbage
        GC.start
        echoln ' done.'
        echoln ''
        return scripts
    end
    
    def self.cleanDirName(name)
        illegal_chars = /[<>:"\/\\|?*\0]/
        sanitized_name = name.gsub(illegal_chars, '')
        return sanitized_name
    end

    def self.createMeta(meta)
        requires = ""
        conflicts = ""
        credits = ""
        optionals = ""
        link = ""
        if meta[:dependencies] != nil 
        meta[:dependencies].each do |dep|
            if dep[0].to_s === "optional"
             optionals += "Optional = #{dep[1]},#{dep[2]}\r\n"
            elsif dep.length == 2
             requires += "Requires = #{dep[0]},#{dep[1]}\r\n"
            else
             requires += "Requires = #{dep}\r\n"
            #   requires += "Requires = #{dep[2]},#{dep[0]},#{dep[1]}\r\n"
            end
        end
        end
        if meta[:incompatibilities] != nil
        meta[:incompatibilities].each do |inc|
            requires += "Conflicts = #{inc}\r\n"
        end
        end
        if meta[:credits] != nil
        credits = "Credits ="
        credit_length = meta[:credits].length
        credit_index = 0
        meta[:credits].each do |credit|
            credits += "#{credit}"
            if credit_index < credit_length - 1
            credits += ","
            end
            credit_index += 1
        end
        end

        if meta[:link] != nil
        link = "Website = #{meta[:link]}\r\n"
        end

        return "Name = #{meta[:name]}\r\nVersion = #{meta[:version]}\r\n#{link}#{requires}#{optionals}#{conflicts}#{credits}\r\n"
    end

end


