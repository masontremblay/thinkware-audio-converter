# Thinkware Audio Converter

-
## Introduction
This macOS application leverages FFmpeg — *"a complete, cross-platform solution to record, convert and stream audio and video"* — to convert MP4 files produced by Thinkware dash cameras (and potentially other dash cameras) into a new, widely compatible version of the same format.
Some Thinkware dash cameras record audio using a format that is not fully supported by many macOS and iOS applications. Because of this, users may be unable to view, trim, or otherwise modify their recorded clips without losing the audio track. This issue is typically identified by a loud "pop" at the beginning of the clip followed by silence for the remainder.

---
## Why This Application Exists
This tool was created to solve a compatibility issue encountered when reviewing dash camera footage on macOS, where audio recorded by certain Thinkware devices fails to play correctly in standard applications such as QuickTime. Rather than relying on proprietary software or complex workflows, this application provides a simple and repeatable method to restore compatibility while preserving original video quality.

---
## Running the Application
Because this app is not from an identified developer, macOS may block it from opening initially. If this happens, you can bypass the warning using either of these methods:
- **Method 1:** The Right-Click Method: Right-click the app in Finder, select Open, and then click Open again in the dialog that appears.
- **Method 2:** The Settings Method: Go to System Settings > Privacy & Security. Scroll down to the Security section and click Open Anyway next to the app's name.
You should only need to do this the first time you launch the application.

___
# How To Use
This application is simple to use and is intended primarily for the purpose described above. You may attempt to use this tool with clips produced by other makes and models of dash cameras; however, results are not guaranteed.

The application requires two things to function:
- At least one MP4 clip intended for conversion  
- A static FFmpeg binary for macOS  

Step-by-step instructions are outlined below. Keep an eye on the **Log** area within the application to monitor progress and assist with troubleshooting.

-
## Step 1: Install Rosetta 2 (Apple Silicon Users)
To use FFmpeg (and by extension, this app) on a Mac with Apple Silicon, you must have Rosetta 2 installed. If you are using an Intel-based Mac or already have Rosetta 2 installed, you can skip this step.
- **Method 1:** Open any application built for Intel processors. macOS will automatically prompt you to install Rosetta.
- **Method 2:** Open Terminal and run the command: softwareupdate --install-rosetta

---
## Step 2: Download FFmpeg
a. Download the static FFmpeg binary for macOS from the official FFmpeg build source:
https://evermeet.cx/ffmpeg/
b. Store the downloaded file in an easily accessible location, such as your Desktop.

---
## Step 3: Prepare Your Video Files
a. Copy the MP4 clips produced by your Thinkware dash camera to an easily accessible location, such as your Desktop.

---
## Step 4: Install the Application
a. Download the Thinkware Audio Converter application.  
b. Move the application to your **Applications** folder.

Optional:  
You may also move the previously downloaded FFmpeg binary to your Applications folder for easier future access.

---
## Step 5: Open the Application
a. Open the Thinkware Audio Converter application.  
b. Navigate to **Step 1** within the application and confirm that you have access to the FFmpeg binary.  
c. If not, press the **Download ffmpeg** button to open the FFmpeg download page.

---
## Step 6: Select Video Files
a. Navigate to **Step 2** in the application.  
b. Press the **Choose MP4 Files** button.  
c. Select the duplicated MP4 clips you wish to convert.

---
## Step 7: Select FFmpeg
a. Navigate to **Step 3** in the application.  
b. Press the **Choose ffmpeg Executable** button.  
c. Select the previously downloaded FFmpeg binary.

The correct file usually:
- Is named **ffmpeg**
- Appears in macOS as a **Unix executable file**

---
## Step 8: Convert Files
a. Navigate to **Step 4** in the application.  
b. Press **Convert Files** to begin the conversion.

---
## Step 9: Locate Converted Files
a. Exit the application.  
b. Navigate to the location where your duplicated files are stored.

Converted files will appear next to the original files and will include a: _converted suffix added to the filename.

---
## Duplicate Handling
If a converted file name already exists in the same location, the application will automatically append an incremental number:

_converted_2
_converted_3

and so on.

No existing files will be overwritten.

---
# Support and Feedback
If you require technical support or would like to provide feedback, please contact:

**Mason**
at pupal-pry.7@icloud.com

I will respond as soon as possible.

---
# Legal and Attributions
Ensure you comply with local laws regarding audio recording and consent. Use this application at your own risk; the developer is not liable for any legal issues, damages, or losses. This software is provided "as is" without warranty. Always back up your original files before use. This application is not affiliated with or endorsed by Thinkware. Thinkware is a trademark of its respective owner. This application uses FFmpeg, which is licensed under the LGPL/GPL. For more information, visit https://ffmpeg.org/.
