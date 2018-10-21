#!/usr/bin/env ruby
#CREATED BY : RAFIE MUHAMMAD
#PROGRAM GO-CLI SEA COMPFEST X 
require "json"

# Class untuk menampilkan Peta
class Show_maps 
    def initialize(data)
        @data = data
        @data_length = data.length - 1
    end
    def show
        (@data_length).downto(0) do |i|
            0.upto(@data_length) do |j|
                print @data[j][i].to_s + " "
            end
            puts ''
        end
        puts "\n**KETERANGAN : 'U' = User , 'D' = Driver"
    end
end

# Class untuk Membuat array peta dengan adanya user dan driver
class Make_maps
    attr_accessor :user,:drivers,:mapsize,:drivers_length
    def initialize(users,drivers,mapsize)
        @users = users
        @drivers = drivers
        @mapsize = mapsize
        @drivers_length = drivers.length - 1
    end

    def make
        @array =Array.new(@mapsize) { Array.new(@mapsize, ".") }
        @array[@users[0]][@users[1]] = "U"
        0.upto(@drivers_length) do |tes|
            @array[@drivers[tes]["coordinate_driver"][0]][@drivers[tes]["coordinate_driver"][1]] = "D"
        end
        @array
    end

end

# Class user
class User
    def initialize(coordinate=[rand(20),rand(20)])
        @coordinate = coordinate
    end

    def coordinate
        @coordinate
    end
end

# Class untuk mendapatkan random driver
class Get_driver_random
    def initialize(mapsize,user)
        @mapsize = mapsize
        @user = user
    end
    def random_drivers
        Drivers_all_random.new(@mapsize,@user).semua_driver
    end
end

# Class driver
class Driver
    attr_accessor :position,:name
    def initialize(mapsize,position,name)
        @mapsize = mapsize
        @position = position
        @name = name
    end
end

# Class untuk genereate info driver secara random
class Drivers_all_random
    @@count = 0
    @@name_list = ["Agus","Supri","Bambang","Mansur","Fadli","Ichsan","Fathan","Anas","Avic","Pradit","Joko",
                    "Dean","Rafie","Rimba","Nizar","Faqih","Hans","Bob","Mike","Dimas","Mufli","Gea","Dias","Gilang",
                    "Bill","Hendro","Sukiman","Sukijan","Supriman","Sudirman","Azmi","Bram","Neil","Broto"]
    def initialize(mapsize,user)
        @mapsize = mapsize
        @driver_name_list = []
        @driver_coor_list = []
        @driver_merge_list = []
        @user = user
    end
    def semua_driver
        while @@count < 5
            @driver_ = Driver.new(@mapsize,[rand(@mapsize),rand(@mapsize)],@@name_list.sample)
            @driver_postion = @driver_.position
            @driver_name = @driver_.name
            if(@driver_coor_list.include? @driver_postion) || (@driver_name_list.include? @driver_name) || (@driver_postion == @user)
                next
            else
                @driver_coor_list.push(@driver_postion)
                @driver_name_list.push(@driver_name)
                @driver_merge_list.push({"name" => @driver_name, "coordinate_driver" => @driver_postion})
                @@count+=1
            end
        end
        @driver_merge_list
    end
end

# Class untuk mencari driver terdekat
class Find_nearest_driver 
    def initialize(users,drivers)
        @users = users
        @drivers = drivers
    end
    def info_driver
        @semua_jarak_driver = []
        @drivers.each { |info| @semua_jarak_driver.push((info["coordinate_driver"][0] - @users[0]).abs + (info["coordinate_driver"][1] - @users[1]).abs) }
        @jarak_terdekat = @semua_jarak_driver.min 
        @index_driver = @semua_jarak_driver.index(@jarak_terdekat)
        @drivers[@index_driver]
    end
    def jarak_driver
        @jarak_terdekat
    end
end

#Class untuk menghitung estimasi harga perjalanan
class Calculate_price
    def initialize(distance,unit_price)
        @distance = distance
        @unit_price = unit_price
    end
    def harga
        @distance * @unit_price
    end
end

#Class untuk menghitung jarak dari user ke tujuan
class Calculate_ke_tujuan
    def initialize(coor_user,coor_tujuan)
        @coor_user = coor_user
        @coor_tujuan = coor_tujuan
    end
    def jarak_ke_tujuan
        (@coor_user[0] - @coor_tujuan[0]).abs + (@coor_user[1] - @coor_tujuan[1]).abs
    end
end

#Class untuk me-generate rute yang akan ditempuh
class Cari_rute
    def initialize(coor_users,coor_tujuan)
        @coor_user = coor_users
        @coor_tujuan = coor_tujuan
        @list_rute = []
    end
    def routes 
        @list_rute.push("start at #{@coor_user}")
        @@coor_update = @coor_user.dup
        @jarak_x = @coor_user[0] - @coor_tujuan[0]
        @jarak_y = @coor_user[1] - @coor_tujuan[1]
        1.upto((@jarak_x).abs) do |i|
            if @jarak_x > 0
                @@coor_update[0]-=1
            elsif @jarak_x < 0
                @@coor_update[0]+=1
            end
            @list_rute.push("go to #{@@coor_update}")
        end
        if (@jarak_x > 0 && @jarak_y < 0) || (@jarak_x < 0 && @jarak_y > 0)
            @list_rute.push("turn right")
        elsif (@jarak_x > 0 && @jarak_y > 0) || (@jarak_x < 0 && @jarak_y < 0)
            @list_rute.push("turn left")
        end
        1.upto((@jarak_y).abs) do |j|
            if @jarak_y > 0
                @@coor_update[1]-=1
            elsif @jarak_y < 0
                @@coor_update[1]+=1
            end
            @list_rute.push("go to #{@@coor_update}")
        end
        @list_rute.push("finish at #{@coor_tujuan}")
        @list_rute
    end
end       

#Class untuk me-manage info detail dari trip
class Detail_trip
    def initialize(user_info,coor_tujuan,driver_info,unit_price)
        @user = user_info
        @coor_tujuan = coor_tujuan
        @unit_price = unit_price
        @driver_info = driver_info
    end

    def destiny_distance
        Calculate_ke_tujuan.new(@user,@coor_tujuan).jarak_ke_tujuan
    end
    
    def price_estimate
        Calculate_price.new(self.destiny_distance,@unit_price).harga
    end

    def trip_routes
        Cari_rute.new(@user,@coor_tujuan).routes
    end

    def show_detail_trip
        Print_detail_trip.new(self.price_estimate,self.trip_routes,@driver_info["name"]).show
    end
end

#Class untuk me print detail trip
class Print_detail_trip
    def initialize(price,rute,info_driver)
        @price = price
        @rute = rute
        @driver_name = info_driver
    end
    def show
        puts ""
        puts "--------Detail Perjalanan--------"
        print "\n@@@INFO DRIVER TERDEKAT@@@"
        print "\nNama Driver : ",@driver_name
        print "\n\n@@@INFO HARGA@@@"
        print "\nEstimasi Harga : ", @price
        print "\n\n@@@INFO RUTE@@@\n"
        @rute.each {|step| print "- " + step + "\n"}
    end
end

#Class untuk menampilkan data riwayat perjalanan user
class Show_history
    def show
        @file = File.read("trip_history.json")
        @data = JSON.parse(@file)["History"]
        print "\n@@@@@@@HISTORY PERJALANAN USER@@@@@@@\n"
        0.upto(@data.length - 1) do |i|
            print "\n====================================================\n"
            Print_detail_trip.new(@data[i]["price"],@data[i]["routes"],@data[i]["driver_name"]).show
            print "\n====================================================\n"
        end
    end
end

#Class untuk menyimpan data riwayat perjalanan user
class Simpan_history
    def initialize(driver_name,rute,price,file)
        @driver_name = driver_name
        @rute = rute
        @price = price
        @file = file
    end
    def simpan
        begin
            @file_history = File.read(@file)
            @data_history = JSON.parse(@file_history)
            @data_masukan = {"driver_name" => @driver_name, "routes" => @rute, "price" => @price}
            @data_history["History"].push(@data_masukan)
            File.write(@file,JSON.pretty_generate(@data_history))
        rescue
            puts "Something wrong with your trip history file !"
            exit()
        end
        puts "Nice,Your Order have been completed"
        puts "Your trip history have benn saved"
        puts "Thanks for using our service :)" 
    end
end

#Class untuk memvalidasi data input yang masuk dari sebuah file untuk argumen
class Check_Input_Data
    attr_accessor :user_coord,:data_drivers,:mapsizee
    def initialize(namafile)
        @namafile = namafile
        @drivers_coor = []
        @drivers_name = []
        @valid_driver = []
    end

    def check_user
        @validate_user = Check_Coordinate.new(@mapsizee,@user_coord).validate
        if @validate_user == false
            puts "User Coordinate melebihi area map !"
            exit()
        end
    end
    def get_file 
        Check_File.new(@namafile).isi
    end
    def check_drivers
        @drivers_coor.each { |i| @valid_driver.push(Check_Coordinate.new(@mapsizee,i).validate)}
        if @valid_driver.include? false
            puts "Ada koordinat driver yang melebihi area !"
            exit()
        end
    end
    def check_data
        @data_input = self.get_file 
        @mapsizee = @data_input["mapsize"]
        @user_coord = @data_input["user_coordinate"]
        @data_drivers = @data_input["driver_info"]
        self.check_user
        @data_drivers.each { |i| @drivers_coor.push(i["coordinate_driver"]) }
        @data_drivers.each { |j| @drivers_name.push(j["name"]) }
        if @data_drivers.length > ((@mapsizee ** 2) - 1)
            puts "Too many drivers !"
            exit()
        elsif (@drivers_coor.detect{ |e| @drivers_coor.count(e) > 1 }) || (@drivers_name.detect{ |e| @drivers_name.count(e) > 1 }) || (@drivers_coor.include? @user_coord)
            puts "There is a duplicate information data info in your file !"
            puts "Maybe same name or coordinate"
            exit()
        else
            self.check_drivers
        end
    end
end

#Class untuk me check apakah suatu coordinate melebihi jangkauan sebuah map
class Check_Coordinate
    def initialize(mapsize,coor)
        @coor = coor
        @mapsize = mapsize
    end
    def validate
        if @coor[0] >= @mapsize || @coor[1] >= @mapsize
            false
        else
            true
        end
    end
end

#Class untuk mengecek kevalidan file input
class Check_File
    def initialize(namafile)
        @namafile = namafile
    end
    def isi
        begin
            @file_input = File.read(@namafile)
            @data_input = JSON.parse(@file_input)
        rescue
            puts "Something error with your input file !"
            exit()
        end
    end
end

# Class untuk menampilkan prompt
class Prompt
    def welcome
        puts "------WELCOME TO GO-CLI APPLICATION------"
        puts "We are here to make your life easier"
    end
    def options
        puts ""
        puts "We offer you 3 options : "
        puts "(1)Show Map"
        puts "(2)Order Go-Ride"
        puts "(3)View History"
        puts ""
        puts "Input your choice : "
    end
    def confirm_prompt
        puts "\n"
        print  "Confirm your Go-Ride Order ?(Y/N) : "
    end
end

#Class untuk mendapatkan lokasi tujuan user
class Get_lokasi_tujuan
    def initialize(mapsize)
        @mapsize = mapsize
    end
    def koor_tujuan
        print "\nMasukan koordinat lokasi tujuan : "
        print "\nKoordinat x : "
        @lokasi_x = gets.chomp
        print "\nKoordinat y : "
        @lokasi_y = gets.chomp
        begin
            @lokasi_x = Integer(@lokasi_x)
            @lokasi_y = Integer(@lokasi_y)
        rescue
            puts "Your input are not Integer !"
            return false
        end
        @koor_user = [@lokasi_x,@lokasi_y]
        if Check_Coordinate.new(@mapsize,@koor_user).validate == false
            puts "Destiny coordinate melebihi area map !"
            false
        else
            @koor_user
        end
    end
end

#Class untuk control konfirmasi user
class Process_confirm
    def initialize(driv_name,rute,price,file)
        @driv_name = driv_name
        @rute = rute
        @price = price
        @file = file
    end
    def validate
        @user_confirm = gets.chomp
        if @user_confirm.upcase == "Y"
            Simpan_history.new(@driv_name,@rute,@price,@file).simpan
            exit()
        elsif  @user_confirm.upcase == "N"
            puts "Canceling Order ..."
        else
            puts "Invalid option !"
        end
        false
    end
end

#Class untuk mengatur jika input awal 3 argv
class Manage_three_args
    attr_reader :mapsize
    def initialize(mapsize,user_x,user_y)
        @mapsize = mapsize
        @user_x = user_x
        @user_y = user_y
    end
    def data
        begin
            @mapsize = Integer(@mapsize)
            @user_x = Integer(@user_x)
            @user_y = Integer(@user_y)
            if @user_x >= @mapsize || @user_y >= @mapsize 
                puts "User coordinate melebihi area map !"
            elsif @mapsize < 0 || @user_x < 0 || @user_y < 0
                puts "We dont accept minus input !"
            elsif @mapsize < 3
                puts "Mapsize too small !"
            else
                @user = User.new([@user_x,@user_y]).coordinate
                @driver = Get_driver_random.new(@mapsize,@user).random_drivers
                return [@user,@driver]
            end
            exit()
        rescue
            puts "Only accept Integer !"
            exit()
        end
    end
end


def main()
    file_history = "trip_history.json"
    set_harga = 500
    args = []
    args = ARGV.dup
    ARGV.clear

    if args.length == 0
        map_size = 20
        users_ = User.new().coordinate
        drivers_ = Get_driver_random.new(map_size,users_).random_drivers
    elsif args.length == 3
        args_3 = Manage_three_args.new(args[0],args[1],args[2])
        data_args_3 = args_3.data
        users_ = data_args_3[0]
        drivers_ = data_args_3[1]
        map_size = args_3.mapsize
    elsif args.length == 1
        data_input = Check_Input_Data.new(args[0])
        data_input.check_data
        users_ = data_input.user_coord
        drivers_ = data_input.data_drivers
        map_size = data_input.mapsizee
    else
        puts "Invalid number of ARGV arguments !"
        exit()
    end

    driver_terdekat = Find_nearest_driver.new(users_,drivers_)
    info_driver = driver_terdekat.info_driver
    prompt = Prompt.new
    prompt.welcome

    while true
        prompt.options
        user_choice = gets.chomp
        if user_choice == "1"
            puts "-------------Here is the Map-------------"
            Show_maps.new(Make_maps.new(users_,drivers_,map_size).make).show
        elsif user_choice == "2"
            koordinat_tujuan = Get_lokasi_tujuan.new(map_size).koor_tujuan
            if koordinat_tujuan == false
                next
            end             
            detail_trip = Detail_trip.new(users_,koordinat_tujuan,info_driver,set_harga)
            price_estimate = detail_trip.price_estimate
            trip_routes = detail_trip.trip_routes
            detail_trip.show_detail_trip

            prompt.confirm_prompt
            Process_confirm.new(info_driver["name"],trip_routes,price_estimate,file_history).validate
        elsif user_choice == "3"
            Show_history.new.show
        else
            puts "Invalide choice !"
            exit()
        end
    end
end

#Jalankan program
main()