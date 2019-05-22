def data_file_path(filename)
  Rails.root.join 'spec/data', filename
end

def data_from_file(filename)
  File.read data_file_path(filename)
end
