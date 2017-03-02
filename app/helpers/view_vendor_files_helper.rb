module ViewVendorFilesHelper
  require 'io/console'

  def jstree_result_hash(path)
    @my_temp_array = Array.new
    @results = Array.new
    @counter = 0
    path_string = path + '/*'
    Dir.glob(path_string) do |file|
      recursive_method(file, '#')
    end
    @sorted_array = @my_temp_array.sort_by{|hash| hash[:text]}
  end

  def recursive_method(file, parent)
    if File.directory?(file)
      name = File.basename file
      @counter += 1
      temp_hash = {:id => "#{@counter}", :parent => "#{parent}", :text => "#{name}"}
      @my_temp_array << temp_hash
      child_path = file + '/*'
      Dir.glob(child_path) do |i|
        recursive_method(i, temp_hash[:id])
      end
    else
      name = File.basename file
      @counter += 1
      temp_hash = {:id => "#{@counter}", :parent => "#{parent}", :text => "#{name}", :icon => 'glyphicon glyphicon-file', :a_attr => {"href": "#{file}"}}
      @my_temp_array << temp_hash
    end
  end



  def vendor_directory(path, vendor)
   vendor_name = vendor.name
   new_path = path + "/#{vendor_name}"
   create_folders(new_path, vendor_name)
  end

  def agreement_directory(path, agreement)
    agreement_rank = agreement.rank
    agreement_name = "agreement-#{agreement_rank}"
    result_array = vendor_directory(path, agreement.vendor)
    new_path =  "#{result_array[2]}" + "/#{agreement_name}"
    create_folders(new_path, agreement_name)
  end

  def task_order_directory(path,task_order)
    task_order_rank = task_order.rank
    task_order_name = "task-order-#{task_order_rank}"
    results_array = agreement_directory(path, task_order.agreement)
    new_path = "#{results_array[2]}" + "/#{task_order_name}"
    create_folders(new_path, task_order_name)
  end

  def create_folders(new_path, name)
    if File.exists?(new_path)
      return false,"Folder labeled - #{name} was already made", new_path, name
    else
      FileUtils.mkdir(new_path)
      return true, "Folder labeled - #{name} was created and can be found in #{new_path}", new_path, name
    end
  end

end
