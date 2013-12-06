Pod::Spec.new do |s|

  s.name         = "MBContactPicker"
  s.version      = "0.0.1"
  s.summary      = "A contact picker that looks like the one in Apple mail for iOS7. This implementation uses a UICollectionView."

  s.description  = <<-DESC
                   MBContactPicker is a library that uses the latest iOS styling and technologies
                   available on iOS.

                   I wrote this library to provide an update to the awesome THContactPicker that
                   we have used in the past. The goal was to provide a library that operated and
                   felt like the native mail app's contact selector.

                   A secondary goal of this project was to create something that was extremely
                   simple to implement if your needs were very basic, yet still provide a high level
                   of flexibility for projects that need a more custom feel.
                   DESC

  s.homepage     = "http://github.com/Citrrus/MBContactPicker"
  s.license      = 'MIT'
  s.author       = { "Matt Bowman" => "mbowman@citrrus.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "http://github.com/Citrrus/MBContactPicker.git", :tag => "0.0.1" }
  s.source_files  = 'MBContactPicker'
  s.requires_arc = true

end
