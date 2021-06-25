Pod::Spec.new do |s|

    s.name = 'Launcher'
    s.version = '1.0.6'
    s.license = { :type => 'MIT' }
    s.homepage = 'https://github.com/iWECon/Launcher'
    s.authors = 'iWw'
    s.ios.deployment_target = '10.0'
    s.summary = 'Launcher'
    s.source = { :git => 'https://github.com/iWECon/Launcher.git', :tag => s.version }
    s.source_files = [
        'Sources/**/*.swift',
    ]
    
    s.cocoapods_version = '>= 1.10.0'
    s.swift_version = ['5.3']
    
    # dependencies
    s.dependency 'RTNavigationController'
    s.dependency 'SegmentedController'
    
end
