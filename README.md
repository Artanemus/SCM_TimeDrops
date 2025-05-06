# SCM_TimeDrops
![image](https://github.com/user-attachments/assets/528a351e-f741-4b47-b469-b5e05a1d01ae)

## An application to connect the SwimClubMeet database to Time Drops timing system.

### To compile this application you need to include. 

- Embarcadero's RAD Studio for Delphi. Architect. (Uses FireDAC for remote TCP/IP DB connection.)
- TMS TDBAdvGrid. A VCL component package. A third party tool.
- FastReports PRO. A VCL component package. A third party tool. (The standard version may also work, untested)
- The Artanemus SCM-SHARED GitHub (public) repository.  
- TurboPack Abbrevia. An open source utility - available on GitHub. (Or Delphi's Getit Package Manager) Used to pack/uppack the application's session for save and load.

### Other notable mentions.

- Ethea SVGIconImageList VCL and FMX. An open source utility - available on GitHub. (Or Delphi's Getit Package Manager) I use Inkscape to build all the graphic items in this application.
- Delphi 'custom style' is Windows10SlateGray
- onryldz x-superobject. A simple JSON Framework - available on GitHub - https://github.com/onryldz/x-superobject. Packaged in SCM_SHARED.
- RRUZ vcl-style-utils. A VCL Styles Utils - available on GitHub - https://github.com/RRUZ/vcl-styles-utils/ . (Used to enlarge the menu font.) Packaged in SCM_SHARED.
- Box2D. An open source 2D physics engine. I'll be using this to create the noodles for patching .... when I get around to it. 😉

### Quick : getting started.

Run the application.

Immediately the 'Directory Watcher' is started. Looking for TimeDrops' 'result' files to enter the designated folder. See MENU: Edit >> Preferences. 

![image](https://github.com/user-attachments/assets/b6c61a69-69a9-42fa-93a9-7147023b8f6f) ![image](https://github.com/user-attachments/assets/c417ffb3-7c18-49de-a0b0-1d75a18bbde3)  ![image](https://github.com/user-attachments/assets/1f1c744b-f73e-452f-9231-9b14c0eaf410)

Connect to the SwimClubMeet MS SQLEXPRESS database server. See MENU: SCM >> Select SCM Session... 

![image](https://github.com/user-attachments/assets/7750d651-8d8b-4b1e-896b-74e49fab315a)

Ensure you have the correct session selected. See MENU: SCM >> Connect to SCM database... 

![image](https://github.com/user-attachments/assets/c2dc0a02-2c06-4282-84fa-7ab0b675ad36)







