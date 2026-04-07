# Thinkware Audio Converter

## Introduction

This macOS application leverages FFmpeg — *"a complete, cross-platform solution to record, convert and stream audio and video"* — to convert MP4 files produced by Thinkware dash cameras (and potentially other dash cameras) into a new, widely compatible version of the same format.

Some Thinkware dash cameras record audio using a format that is not fully supported by many macOS and iOS applications. Because of this, users may be unable to view, trim, or otherwise modify their recorded clips without losing the audio track. This issue is typically identified by a loud "pop" at the beginning of the clip followed by silence for the remainder.

---

## Why This Application Exists

This tool was created to solve a compatibility issue encountered when reviewing dash camera footage on macOS, where audio recorded by certain Thinkware devices fails to play correctly in standard applications such as QuickTime. Rather than relying on proprietary software or complex workflows, this application provides a simple and repeatable method to restore compatibility while preserving original video quality.

---

## Running the App

If macOS warns that the application cannot be opened, right-click the app in Finder, choose Open, and then confirm. You may need to do this the first time you launch the app.

___

# How To Use

This application is simple to use and is intended primarily for the purpose described above. You may attempt to use this tool with clips produced by other makes and models of dash cameras; however, results are not guaranteed.

The application requires two things to function:

- At least one MP4 clip intended for conversion  
- A static FFmpeg binary for macOS  

Step-by-step instructions are outlined below. Keep an eye on the **Log** area within the application to monitor progress and assist with troubleshooting.

---

## Step 1 — Download FFmpeg

a. Download the static FFmpeg binary for macOS from the official FFmpeg build source:

https://evermeet.cx/ffmpeg/

b. Store the downloaded file in an easily accessible location, such as your Desktop.

---

## Step 2 — Prepare Your Video Files

a. Copy the MP4 clips produced by your Thinkware dash camera to an easily accessible location, such as your Desktop.

---

## Step 3 — Install the Application

a. Download the Thinkware Audio Converter application.  
b. Move the application to your **Applications** folder.

Optional:  
You may also move the previously downloaded FFmpeg binary to your Applications folder for easier future access.

---

## Step 4 — Open the Application

a. Open the Thinkware Audio Converter application.  
b. Navigate to **Step 1** within the application and confirm that you have access to the FFmpeg binary.  
c. If not, press the **Download ffmpeg** button to open the FFmpeg download page.

---

## Step 5 — Select Video Files

a. Navigate to **Step 2** in the application.  
b. Press the **Choose MP4 Files** button.  
c. Select the duplicated MP4 clips you wish to convert.

---

## Step 6 — Select FFmpeg

a. Navigate to **Step 3** in the application.  
b. Press the **Choose ffmpeg Executable** button.  
c. Select the previously downloaded FFmpeg binary.

The correct file usually:

- Is named **ffmpeg**
- Appears in macOS as a **Unix executable file**

---

## Step 7 — Convert Files

a. Navigate to **Step 4** in the application.  
b. Press **Convert Files** to begin the conversion.

---

## Step 8 — Locate Converted Files

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
pupal-pry.7@icloud.com

I will respond as soon as possible.

---

# Legal and Attributions

Recording conversations or voices may be restricted or illegal in some regions without consent. You are responsible for understanding and complying with local laws before recording or using audio from your device. Use this application at your own risk. The developer is not responsible for any legal issues, damages, or losses resulting from use or misuse of this application. This application is provided free of charge and may be used and shared freely. No commercial warranty is provided. Always keep backups of your original videos before using this application. The application is provided *"as is"* without warranties of any kind, express or implied, including but not limited to fitness for a particular purpose and noninfringement. This application is not affiliated with, endorsed by, or approved for use by Thinkware or any of its affiliates. **Thinkware** or **THINKWARE** is a trademark of its respective owner and is used for identification purposes only. Such use does not imply endorsement. This application uses **FFmpeg**, © the FFmpeg developers. FFmpeg is licensed under the LGPL or GPL depending on configuration. For more information, licensing details, and source code, visit: https://ffmpeg.org/
