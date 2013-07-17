Pod::Spec.new do |s|
  s.name         = 'CMDataStorage'
  s.version      = '1.0.0'
  s.summary      = 'Simple and powerful API for read / write NSData from / to iOS Cache / Documents / Tmp folder'
  s.author = {
    'Constantine Mureev' => 'mureev@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/mureev/CMDataStorage.git',
    :tag => '1.0.0'
  }
  s.source_files = 'CMDataStorage/*.{h,m}'
end