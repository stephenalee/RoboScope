# RoboScope
Code to Automate some microscopy tasks with Matlab and Micro-Manager



## Installation ##
Install Micro-Manager from [https://micro-manager.org/wiki/Download%20Micro-Manager_Latest%20Release](https://micro-manager.org/wiki/Download%20Micro-Manager_Latest%20Release "Micro-Manager Downloads page")

Setup your Micro-Manager configuration file with your hardware, and especially make sure to have your focus piezo set as the Focus Device in Micro-Manager.

To setup Matlab controlling Micro-Manager for the first time, add the to Micro-Manager install directory to the path (or simply navigate to it as the working directory) and run STARTMMSTUDIO('-setup'). This will set up the correct classpaths etc, and after it's complete you'll need to restart Matlab.

## Starting Micro-Manager in Matlab ##
After the one-time setup with STARTMMSTUDIO('-setup') has been accomplished you can open Micro-Manager in Matlab. I recommend using my script StartupNprep.m to do this.

To see an example of automating an experiment see RunExperiment_Ben.m

## Notes

See AutoFocus_guide.pdf for more information regarding the autofocus functionality.

I expect that any programs my name (Ben) in the title are likely fairly specifically written for my purposes and will need to be modified for your purposes. That being said, they may be useful starting points for any programs you may need to accomplish similar tasks.

## Contributing

1. Please inform me before making any changes, then follow the directions below: 
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D



## License

                      GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

  See LICENSE.txt