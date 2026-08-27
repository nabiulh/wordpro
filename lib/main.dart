import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2b579a),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const WordProApp());
}

class WordProApp extends StatelessWidget {
  const WordProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2b579a)),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;

  final String editorHtmlContent = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
    <title>Word Pro</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Anek+Bangla:wght@300;400;600&family=Atma:wght@400;600&family=Baloo+Da+2:wght@400;600&family=Baskervville:ital@0;1&family=Caveat:wght@400;600&family=Cinzel:wght@400;700&family=Cormorant+Garamond:wght@400;600&family=Dancing+Script:wght@400;600&family=Fira+Code:wght@400;600&family=Galada&family=Handlee&family=Hind+Siliguri:wght@300;400;500;600;700&family=Homemade+Apple&family=Indie+Flower&family=Josefin+Sans:wght@400;600&family=Kalam:wght@400;700&family=Lato:wght@400;700&family=Libre+Baskerville:wght@400;700&family=Libre+Franklin:wght@400;600&family=Lobster&family=Lora:wght@400;600&family=Merriweather:wght@400;700&family=Mina:wght@400;700&family=Montserrat:wght@600;700&family=Mukta+Mahee:wght@400;600&family=Noto+Sans+Bengali:wght@300;400;500;600;700&family=Noto+Serif+Bengali:wght@400;600&family=Open+Sans:wght@400;600&family=Oswald:wght@400;600&family=Pacifico&family=Patrick+Hand&family=Playfair+Display:wght@400;600;700&family=Poppins:wght@400;600&family=Raleway:wght@400;600&family=Righteous&family=Roboto:wght@400;500;700&family=Sacramento&family=Satisfy&family=Shadows+Into+Light&family=Source+Sans+3:wght@400;600&family=Tiro+Bangla:ital@0;1&family=Alex+Brush&family=Courgette&family=Great+Vibes&family=Kaushan+Script&family=Tangerine:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <style>
        :root {
            --word-blue: #2b579a; --word-bg: #f3f2f1; --word-border: #e1dfdd; --word-hover: #e1dfdd;
            --page-width: 794px;
            --page-height: 1123px;
            --page-gap: 40px;
            --page-margin: 96px;
        }
        
        html, body { 
            height: 100%; margin: 0; padding: 0; 
            font-family: 'Calibri', 'Hind Siliguri', sans-serif;
            background-color: #e5e7eb; 
            overflow: hidden; 
            display: flex; flex-direction: column;
        }

        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        .workspace-scroll::-webkit-scrollbar { width: 12px; }
        .workspace-scroll::-webkit-scrollbar-track { background: #e5e7eb; }
        .workspace-scroll::-webkit-scrollbar-thumb { background: #c1c1c1; border-radius: 6px; border: 3px solid #e5e7eb; }
        .workspace-scroll::-webkit-scrollbar-thumb:hover { background: #a8a8a8; }

        .title-bar { background-color: var(--word-blue); color: white; display: flex; justify-content: space-between; align-items: center; padding: 0 10px; height: 30px; font-size: 12px; user-select: none; flex-shrink: 0; z-index: 50;}
        .tabs-bar { background-color: var(--word-blue); display: flex; padding: 0 10px; align-items: flex-end; overflow-x: auto; white-space: nowrap; flex-shrink: 0; z-index: 50;}
        .tab-btn { padding: 4px 12px; cursor: pointer; color: white; font-size: 13px; margin-right: 2px; transition: background 0.2s; border-top-left-radius: 2px; border-top-right-radius: 2px;}
        .tab-btn:hover { background-color: rgba(255,255,255,0.1); }
        .tab-btn.active { background-color: var(--word-bg); color: var(--word-blue); font-weight: bold;}
        .tab-btn.file-btn { background-color: #1a365d; }

        .ribbon-area { background-color: var(--word-bg); border-bottom: 1px solid var(--word-border); display: flex; flex-direction: column; flex-shrink: 0; z-index: 50;}
        .ribbon-groups { display: none; padding: 5px; gap: 5px; overflow-x: auto; scroll-behavior: smooth; white-space: nowrap; height: 95px;}
        .ribbon-groups.active { display: flex; } 
        
        .r-group { border-right: 1px solid var(--word-border); padding-right: 8px; display: flex; flex-direction: column; justify-content: space-between; min-width: max-content;}
        .r-group:last-child { border-right: none; }
        .r-row { display: flex; gap: 3px; align-items: center; }
        
        .r-btn { background: transparent; border: 1px solid transparent; border-radius: 2px; padding: 3px 5px; cursor: pointer; display: inline-flex; flex-direction: column; align-items: center; justify-content: center; font-size: 13px; color: #3b3a39;}
        .r-btn:hover { background-color: var(--word-hover); border-color: #c8c6c4; }
        .r-btn-small { padding: 3px; font-size: 12px; display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; }
        .r-select { border: 1px solid #8a8886; font-size: 12px; padding: 2px; outline: none; background: white;}

        .quick-access-bar { background-color: var(--word-bg); border-bottom: 1px solid #d1d5db; display: flex; align-items: center; padding: 2px 10px; gap: 8px; font-size: 12px; color: #3b3a39; overflow-x: auto; flex-shrink: 0; z-index: 50;}

        .status-bar { background-color: var(--word-bg); border-top: 1px solid var(--word-border); color: #3b3a39; font-size: 11px; display: flex; justify-content: space-between; align-items: center; padding: 2px 15px; flex-shrink: 0; white-space: nowrap; overflow-x: auto; gap: 10px; z-index: 50;}
        .status-item { cursor: pointer; padding: 2px 5px; }
        .status-item:hover { background-color: var(--word-hover); }

        .mobile-bottom-bar { display: none; background-color: #ffffff; border-top: 1px solid #d1d5db; padding: 8px 10px; justify-content: flex-start; align-items: center; flex-shrink: 0; overflow-x: auto; gap: 8px; box-shadow: 0 -2px 10px rgba(0,0,0,0.05); z-index: 50;}
        .m-btn { background: #f3f2f1; border: 1px solid #e1dfdd; border-radius: 6px; padding: 8px 14px; font-size: 16px; color: var(--word-blue); display: inline-flex; align-items: center; justify-content: center; font-weight: bold; flex-shrink: 0; transition: all 0.2s;}
        .m-btn:active { background: #e5e7eb; transform: scale(0.95);}

        @media (max-width: 768px) {
            .mobile-bottom-bar { display: flex; }
            .status-bar { display: none; }
        }

        .workspace { flex: 1; overflow-y: auto; overflow-x: auto; background-color: #e5e7eb; display: flex; justify-content: center; padding: 30px 10px 60px 10px; touch-action: pan-x pan-y;}
        
        #zoomWrapper {
            transform-origin: top center;
            transition: transform 0.15s ease-out;
            width: var(--page-width);
            display: flex; flex-direction: column; align-items: center;
        }

        #document-wrapper {
            width: var(--page-width);
            display: flex;
            flex-direction: column;
            gap: var(--page-gap);
        }

        .page {
            width: var(--page-width);
            height: var(--page-height);
            background-color: #ffffff;
            box-shadow: 0px 6px 15px rgba(0,0,0,0.2);
            position: relative;
            display: flex;
            flex-direction: column;
            box-sizing: border-box;
            padding: var(--page-margin) var(--page-margin) 0 var(--page-margin);
        }

        .page-border-layer {
            position: absolute;
            top: 15px; bottom: 15px; left: 15px; right: 15px;
            pointer-events: none;
            z-index: 10;
            display: none;
        }
        .page-border-layer[class*="border-s"] { display: block; }

        .pb-text { position: absolute; font-family: 'Cinzel', 'Montserrat', sans-serif; font-weight: 700; z-index: 2;}
        .pb-text span { background: white; padding: 0 6px; display: inline-flex; align-items: center; gap: 4px; }
        
        .pb-top { top: 0; left: 50%; width: 100%; transform: translate(-50%, -50%); display: flex; justify-content: space-between; align-items: center; font-size: 11px; padding: 0 20px; }
        .pb-bottom { bottom: 0; left: 50%; transform: translate(-50%, 50%); font-size: 11px; padding: 0 15px; letter-spacing: 0.5px;}
        .pb-left { left: 0; top: 50%; transform: translate(-50%, -50%) rotate(-90deg); font-size: 9px; padding: 0 10px; letter-spacing: 1px; white-space: nowrap;}
        .pb-right { right: 0; top: 50%; transform: translate(50%, -50%) rotate(90deg); font-size: 9px; padding: 0 10px; letter-spacing: 1px; white-space: nowrap;}

        .corner { position: absolute; width: 10px; height: 10px; background: white; z-index: 2; display: none; }
        .pb-tl { top: -5px; left: -5px; } .pb-tr { top: -5px; right: -5px; } .pb-bl { bottom: -5px; left: -5px; } .pb-br { bottom: -5px; right: -5px; }

        body.hide-decorations .page-header, 
        body.hide-decorations .page-border-layer {
            display: none !important;
        }

        .border-s1 { border: 4px double #000; } .border-s1 .corner { display: block; border: 1px solid #000; } .border-s1 .pb-text { color: #000; }
        .border-s2 { border: 4px double #1e3a8a; } .border-s2 .corner { display: block; border: 1px solid #1e3a8a; } .border-s2 .pb-text { color: #1e3a8a; }
        .border-s3 { border: 2px solid #000; } .border-s3 .pb-text { color: #000; }
        .border-s4 { border: 2px solid #2563eb; } .border-s4 .pb-text { color: #2563eb; }
        .border-s5 { border: 2px dashed #000; } .border-s5 .pb-text { color: #000; }
        .border-s6 { border: 2px dashed #3b82f6; } .border-s6 .pb-text { color: #3b82f6; }
        .border-s7 { border: 3px dotted #000; } .border-s7 .pb-text { color: #000; }
        .border-s8 { border: 4px groove #9ca3af; } .border-s8 .pb-text { color: #4b5563; }
        .border-s9 { border: 4px ridge #6b7280; } .border-s9 .pb-text { color: #374151; }
        .border-s10 { border: 2px solid #000; border-radius: 20px; } .border-s10 .pb-text { color: #000; }
        .border-s11 { border: 2px solid #1d4ed8; border-radius: 20px; } .border-s11 .pb-text { color: #1d4ed8; }
        .border-s12 { border: 3px inset #d1d5db; } .border-s12 .pb-text { color: #4b5563; }
        .border-s13 { border: 3px outset #d1d5db; } .border-s13 .pb-text { color: #4b5563; }
        .border-s14 { border: 3px double #b8860b; } .border-s14 .pb-text { color: #b8860b; }
        .border-s15 { border: 4px double #064e3b; } .border-s15 .pb-text { color: #064e3b; }
        .border-s16 { border: 4px double #991b1b; } .border-s16 .pb-text { color: #991b1b; }
        .border-s17 { border: 1px solid #000; } .border-s17 .pb-text { color: #000; }
        .border-s18 { border: 1px solid #1e3a8a; } .border-s18 .pb-text { color: #1e3a8a; }
        .border-s19 { box-shadow: 0 0 0 1px #000, 0 0 0 3px #fff, 0 0 0 4px #000; } .border-s19 .pb-text { color: #000; }
        .border-s20 { border: 1px solid #0f172a; } .border-s20 .pb-text { color: #0f172a; }

        .page-header { min-height: 40px; margin-top: -15px; position: relative; z-index: 20; }
        .compact-header { border-bottom: 3px double #1e3a8a; background: linear-gradient(to right, #ffffff, #f4f7fa, #ffffff); color: inherit; padding: 8px 10px 6px 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; position: relative; }
        .header-edit { cursor: text; pointer-events: auto; padding: 1px 4px; border-radius: 3px; border: 1px solid transparent; transition: all 0.2s; display: inline-block;}
        .header-edit:hover { background: rgba(59, 130, 246, 0.1); border-color: rgba(59, 130, 246, 0.3); }
        .header-edit:focus { outline: none; background: rgba(59, 130, 246, 0.15); border-color: #3b82f6; }
        .topic-edit { pointer-events: auto; cursor: text; min-width: 150px; display: inline-block; border-bottom: 1px dashed #93c5fd;}
        .topic-edit:empty:before { content: attr(data-placeholder); color: #94a3b8; cursor: text; font-weight: normal;}
        
        .text-3d { font-weight: bold; text-shadow: none !important; }

        .page-content { flex: 1; outline: none; overflow-y: hidden; word-wrap: break-word; line-height: 1.6; font-size: 16px; text-align: left; margin-bottom: 25px; position: relative; z-index: 20; }
        .page-content:empty:before { content: attr(data-placeholder); color: #9ca3af; pointer-events: none; }
        .page-content div, .page-content p { margin-bottom: 0.8em; break-inside: auto; }
        .page-content table { width: 100%; border-collapse: collapse; margin-bottom: 1em; }
        .page-content table, .page-content th, .page-content td { border: 1px solid #94a3b8; padding: 8px; }

        .page-footer { height: 30px; display: flex; justify-content: center; align-items: center; color: #9ca3af; font-size: 12px; border-top: 1px dashed transparent; user-select: none; position: absolute; bottom: 15px; left: 0; width: 100%; z-index: 20; }

        .l-spacing-200 { line-height: 2.0 !important; } .l-spacing-150 { line-height: 1.5 !important; }
        .l-spacing-115 { line-height: 1.15 !important; } .l-spacing-100 { line-height: 1.0 !important; }

        @media print {
            html, body { height: 100% !important; max-height: 100% !important; overflow: visible !important; background-color: white !important; margin: 0 !important; padding: 0 !important; }
            .title-bar, .tabs-bar, .ribbon-area, .quick-access-bar, .status-bar, .mobile-bottom-bar, #toast, #historyModal, #customModal, #globalFontMegaMenu, #globalFontSizeMenu { display: none !important; }
            .workspace { padding: 0 !important; margin: 0 !important; background-color: white !important; overflow: visible !important; display: block !important; height: auto !important; min-height: 0 !important; }
            #zoomWrapper, #document-wrapper { transform: none !important; zoom: 1 !important; width: 100% !important; gap: 0 !important; display: block !important; margin: 0 !important; padding: 0 !important; height: auto !important; }
            
            .page {
                box-shadow: none !important; margin: 0 !important;
                padding: var(--page-margin) var(--page-margin) 0 var(--page-margin) !important;
                width: 210mm !important; height: 297mm !important; max-height: 297mm !important;
                box-sizing: border-box !important; page-break-inside: avoid !important; break-inside: avoid !important; overflow: hidden !important;
                print-color-adjust: exact !important; -webkit-print-color-adjust: exact !important; position: relative;
                break-before: always !important; page-break-before: always !important;
            }
            .page.print-first-page { break-before: avoid !important; page-break-before: avoid !important; }
            .page:last-child { page-break-after: avoid !important; break-after: avoid !important; }

            .page-border-layer { display: block !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important;}
            .page-border-layer[class*="border-none"] { display: none !important; }
            
            .empty-page { display: none !important; height: 0 !important; width: 0 !important; margin: 0 !important; padding: 0 !important; border: none !important; overflow: hidden !important; page-break-before: avoid !important; break-before: avoid !important; page-break-after: avoid !important; break-after: avoid !important; }
            .page-footer { display: flex !important; }
            .topic-edit:empty { display: none !important; margin: 0 !important; padding: 0 !important; height: 0 !important; border: none !important; }
            .header-edit { border: none !important; background: transparent !important; }
            .topic-edit { border-bottom: none !important; }
            .text-3d { text-shadow: none !important; }
            @page { size: A4 portrait; margin: 0; }
        }
    </style>
</head>
<body>
    <div id="toast" class="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-gray-900/95 text-white px-6 py-3 rounded shadow-2xl transition-all duration-300 opacity-0 pointer-events-none z-[200] flex items-center gap-2 font-bold text-sm tracking-wide">
        <i class="fa-solid fa-circle-info text-blue-400"></i> <span id="toastMessage"></span>
    </div>

    <div id="customModal" class="hidden fixed inset-0 bg-black/50 z-[300] flex items-center justify-center p-4">
        <div class="bg-white rounded shadow-xl w-full max-w-sm overflow-hidden border border-gray-300">
            <div class="bg-[#2b579a] text-white px-4 py-2 font-semibold text-sm flex items-center gap-2" id="modalTitle">
                <i class="fa-solid fa-pencil"></i> <span>Notice</span>
            </div>
            <div class="p-4 bg-[#f3f2f1]">
                <p id="modalMessage" class="text-sm text-gray-800 mb-3"></p>
                <input type="text" id="modalInput" class="hidden w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:border-[#2b579a] mb-4 bg-white">
                <div class="flex justify-end gap-2">
                    <button id="modalCancel" class="px-4 py-1.5 text-sm text-gray-700 bg-gray-200 hover:bg-gray-300 border border-gray-300 rounded transition-colors">Cancel</button>
                    <button id="modalOk" class="px-4 py-1.5 text-sm bg-[#2b579a] text-white hover:bg-blue-800 rounded transition-colors">OK</button>
                </div>
            </div>
        </div>
    </div>

    <div id="globalFontMegaMenu" class="hidden absolute w-72 sm:w-[450px] bg-white border border-gray-300 shadow-2xl z-[500] flex flex-col rounded overflow-hidden">
        <div class="flex bg-gray-100 border-b w-full">
           <button onclick="switchFontTab('eng', this)" class="font-tab flex-1 py-2 text-[11px] font-bold border-b-2 border-blue-600 text-blue-600 tracking-wide uppercase transition">English</button>
           <button onclick="switchFontTab('ben', this)" class="font-tab flex-1 py-2 text-[11px] font-bold border-b-2 border-transparent text-gray-600 tracking-wide uppercase transition">Bengali</button>
           <button onclick="switchFontTab('hand', this)" class="font-tab flex-1 py-2 text-[11px] font-bold border-b-2 border-transparent text-gray-600 tracking-wide uppercase transition">Handwriting</button>
           <button onclick="switchFontTab('mixed', this)" class="font-tab flex-1 py-2 text-[11px] font-bold border-b-2 border-transparent text-gray-600 tracking-wide uppercase transition">Smart Mixed</button>
        </div>
        <div class="flex-1 overflow-y-auto p-2 workspace-scroll max-h-[50vh] bg-white" id="fontTabContent"></div>
    </div>

    <div id="globalFontSizeMenu" class="hidden absolute w-16 bg-white border border-gray-300 shadow-xl z-[500] max-h-[40vh] overflow-y-auto workspace-scroll text-sm rounded"></div>

    <div class="title-bar">
        <div class="flex items-center gap-4 w-1/3">
            <button onclick="autoSave()" class="hover:bg-white/20 px-2 py-1 rounded" title="Save"><i class="fa-regular fa-floppy-disk"></i></button>
        </div>
        <div class="text-center w-1/3 flex justify-center items-center gap-2 font-semibold tracking-wide bg-blue-800/50 rounded px-4 py-0.5 truncate">
            Word Pro - Editor
        </div>
        <div class="flex justify-end items-center gap-3 w-1/3 text-sm">
            <button onclick="printDocument()" class="hover:bg-white/20 px-2 py-1"><i class="fa-solid fa-print"></i></button>
        </div>
    </div>

    <div class="tabs-bar no-scrollbar" id="mainTabs">
        <div class="tab-btn file-btn" onclick="openHistoryModal()">File</div>
        <div class="tab-btn active" onclick="switchTab(this, 'tab-home')">Home</div>
        <div class="tab-btn" onclick="switchTab(this, 'tab-insert')">Insert</div>
        <div class="tab-btn" onclick="switchTab(this, 'tab-layout')">Layout</div>
        <div class="tab-btn" onclick="switchTab(this, 'tab-view')">View</div>
        <div class="tab-btn ml-auto bg-blue-800 rounded px-3 relative" onclick="toggleShareDropdown()" id="shareDropdownContainer">
            <i class="fa-solid fa-share-nodes"></i> Export
            <div id="shareDropdown" class="absolute top-8 right-0 w-48 bg-white border border-gray-200 shadow-xl hidden z-50 text-gray-800 rounded">
                <button onclick="downloadTxt();" class="w-full text-left px-4 py-2 hover:bg-gray-100 flex items-center gap-2 text-sm border-b"><i class="fa-regular fa-file-lines text-gray-500"></i> Export Text</button>
                <button onclick="exportPDF();" class="w-full text-left px-4 py-2 hover:bg-gray-100 flex items-center gap-2 text-sm"><i class="fa-solid fa-file-pdf text-red-500"></i> Export PDF</button>
            </div>
        </div>
    </div>

    <div class="ribbon-area">
        <div id="tab-home" class="ribbon-groups active no-scrollbar">
            <div class="r-group">
                <div class="flex gap-1 h-full items-center">
                    <button onclick="printDocument()" class="r-btn" style="height:100%" title="Print Document">
                        <i class="fa-solid fa-print text-[22px] text-blue-700 mb-1"></i>
                        <span class="text-[11px] font-bold">Print</span>
                    </button>
                    <div class="flex flex-col gap-0.5 justify-center">
                        <button onclick="createNewDocument()" class="r-btn r-btn-small flex-row gap-1 w-auto" title="New File"><i class="fa-solid fa-file-circle-plus text-green-600"></i></button>
                        <button onclick="customPaste()" class="r-btn r-btn-small flex-row gap-1 w-auto" title="Paste"><i class="fa-solid fa-paste text-yellow-600"></i></button>
                        <button onclick="customCut()" class="r-btn r-btn-small flex-row gap-1 w-auto" title="Cut"><i class="fa-solid fa-scissors text-gray-600"></i></button>
                    </div>
                </div>
            </div>

            <div class="r-group">
                <div class="flex gap-1 mb-1">
                    <button onclick="toggleFontMenu(this)" id="fontBtnDisplay" class="r-select w-28 sm:w-36 flex justify-between items-center text-left bg-white cursor-pointer font-sans" title="Font Style">
                        <span class="truncate" id="currentFontDisplay">Calibri</span> <i class="fa-solid fa-chevron-down text-[10px] text-gray-500 ml-1"></i>
                    </button>
                    <div class="flex items-center gap-0.5">
                        <button onclick="toggleFontSizeMenu(this)" id="fontSizeDisplay" class="r-select w-12 flex justify-between items-center text-left bg-white cursor-pointer font-sans" title="Font Size">
                            <span id="currentFontSize">16</span> <i class="fa-solid fa-chevron-down text-[10px] text-gray-500 ml-1"></i>
                        </button>
                        <button onclick="changeFontSizeBy(1)" class="r-btn r-btn-small ml-0.5 relative text-blue-800"><i class="fa-solid fa-A font-bold text-sm"></i><i class="fa-solid fa-caret-up absolute top-0.5 right-0.5 text-[8px]"></i></button>
                        <button onclick="changeFontSizeBy(-1)" class="r-btn r-btn-small relative text-blue-800"><i class="fa-solid fa-A text-xs"></i><i class="fa-solid fa-caret-down absolute top-0.5 right-0.5 text-[8px]"></i></button>
                    </div>
                </div>
                <div class="flex gap-0.5">
                    <button onmousedown="event.preventDefault();" onclick="execCmd('bold')" class="r-btn r-btn-small font-bold" title="Bold">B</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('italic')" class="r-btn r-btn-small italic font-serif" title="Italic">I</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('underline')" class="r-btn r-btn-small underline" title="Underline">U</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('strikeThrough')" class="r-btn r-btn-small line-through" title="Strikethrough">ab</button>
                    <div class="w-px h-4 bg-gray-300 mx-1 mt-1"></div>
                    <label class="r-btn r-btn-small cursor-pointer border-b-4 border-yellow-400" title="Highlight" onmousedown="saveSelection()">
                        <i class="fa-solid fa-pen" style="color:black"></i>
                        <input type="color" oninput="applyColor('hiliteColor', this.value); this.parentElement.style.borderColor = this.value;" class="w-0 h-0 opacity-0 absolute" value="#ffff00">
                    </label>
                    <label class="r-btn r-btn-small cursor-pointer border-b-4 border-red-600 font-bold" title="Font Color" onmousedown="saveSelection()">
                        A
                        <input type="color" oninput="applyColor('foreColor', this.value); this.parentElement.style.borderColor = this.value;" class="w-0 h-0 opacity-0 absolute">
                    </label>
                    <button onclick="execCmd('removeFormat')" class="r-btn r-btn-small ml-1 text-gray-500"><i class="fa-solid fa-eraser"></i></button>
                </div>
            </div>

            <div class="r-group">
                <div class="flex gap-0.5 mb-1">
                    <button onmousedown="event.preventDefault();" onclick="execCmd('insertUnorderedList')" class="r-btn r-btn-small"><i class="fa-solid fa-list-ul"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('insertOrderedList')" class="r-btn r-btn-small"><i class="fa-solid fa-list-ol"></i></button>
                    <div class="w-px h-4 bg-gray-300 mx-1 mt-1"></div>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('outdent')" class="r-btn r-btn-small"><i class="fa-solid fa-indent fa-flip-horizontal"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('indent')" class="r-btn r-btn-small"><i class="fa-solid fa-indent"></i></button>
                </div>
                <div class="flex gap-0.5">
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyLeft')" class="r-btn r-btn-small"><i class="fa-solid fa-align-left"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyCenter')" class="r-btn r-btn-small"><i class="fa-solid fa-align-center"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyRight')" class="r-btn r-btn-small"><i class="fa-solid fa-align-right"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyFull')" class="r-btn r-btn-small"><i class="fa-solid fa-align-justify"></i></button>
                    <div class="w-px h-4 bg-gray-300 mx-1 mt-1"></div>
                    <select id="lineSpacingSelector" onchange="changeLineSpacing(this.value)" class="r-select w-14">
                        <option value="200">2.0</option><option value="150" selected>1.5</option><option value="115">1.1</option><option value="100">1.0</option>
                    </select>
                </div>
            </div>

            <div class="r-group">
                <div class="flex gap-1 h-full items-center px-2">
                    <button id="btnAutoBold" onclick="applyAutoBold()" class="r-btn text-purple-700 font-bold border border-purple-200 bg-purple-50 shadow-sm" style="height: 100%">
                        <i class="fa-solid fa-wand-magic-sparkles text-lg"></i><span>Auto Bold</span>
                    </button>
                    <button id="btnAutoFix" onclick="applyAutoFix()" class="r-btn text-green-700 font-bold border border-green-200 bg-green-50 shadow-sm" style="height: 100%">
                        <i class="fa-solid fa-check-double text-lg"></i><span>AutoFix</span>
                    </button>
                </div>
            </div>
        </div>

        <div id="tab-insert" class="ribbon-groups no-scrollbar">
            <div class="r-group"><div class="flex gap-1 h-full"><button onclick="execCmd('insertHorizontalRule')" class="r-btn h-full"><i class="fa-solid fa-file-lines text-xl text-blue-500 mb-1"></i><span class="text-[11px]">Break</span></button><button onclick="insertTable()" class="r-btn h-full"><i class="fa-solid fa-table text-xl text-orange-600 mb-1"></i><span class="text-[11px]">Table</span></button></div></div>
            <div class="r-group"><div class="flex gap-1 h-full"><label class="r-btn h-full cursor-pointer"><i class="fa-regular fa-image text-xl text-green-600 mb-1"></i><span class="text-[11px]">Pictures</span><input type="file" accept="image/*" onchange="insertImage(this)" class="hidden"></label></div></div>
            <div class="r-group"><div class="flex gap-1 h-full"><button onclick="insertLink()" class="r-btn h-full"><i class="fa-solid fa-link text-xl text-gray-600 mb-1"></i><span class="text-[11px]">Link</span></button></div></div>
        </div>

        <div id="tab-layout" class="ribbon-groups no-scrollbar">
            <div class="r-group bg-blue-50/50">
                <div class="flex flex-col gap-1 px-1 justify-center h-full">
                    <span class="text-[11px] font-bold text-blue-800">Border Style:</span>
                    <select id="borderSelector" onchange="changeBorderStyle(this.value)" class="r-select w-36 font-semibold border-blue-300">
                        <option value="border-none">None</option>
                        <option value="border-s1" selected>Style 1 (Classic)</option>
                        <option value="border-s2">Style 2 (Double Blue)</option>
                        <option value="border-s3">Style 3 (Solid Black)</option>
                        <option value="border-s4">Style 4 (Solid Blue)</option>
                        <option value="border-s10">Style 10 (Rounded)</option>
                        <option value="border-s14">Style 14 (Gold)</option>
                    </select>
                </div>
            </div>
            <div class="r-group">
                <div class="flex gap-1 h-full items-center px-2">
                    <div class="flex flex-col gap-1">
                        <span class="text-[11px] font-semibold text-gray-700">Columns:</span>
                        <select id="columnSelector" onchange="changeColumns(this.value)" class="r-select w-28">
                            <option value="1" selected>One Column</option>
                            <option value="2">Two Columns</option>
                            <option value="3">Three Columns</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <div id="tab-view" class="ribbon-groups no-scrollbar">
            <div class="r-group">
                <div class="flex gap-1 h-full items-center px-2">
                    <button onclick="setZoom(100)" class="r-btn h-full"><i class="fa-solid fa-magnifying-glass text-xl text-blue-600 mb-1"></i><span class="text-[11px]">100%</span></button>
                    <button onclick="fitToScreen()" class="r-btn h-full"><i class="fa-solid fa-expand text-xl text-gray-600 mb-1"></i><span class="text-[11px]">Fit</span></button>
                </div>
            </div>
            <div class="r-group">
                <div class="flex gap-1 h-full items-center px-2">
                    <label class="flex items-center gap-1.5 cursor-pointer text-[11px] font-bold text-gray-700 bg-white border border-gray-300 px-2 py-1 rounded">
                        <input type="checkbox" id="toggleDecorationsBtn" checked onchange="toggleDecorations(this.checked)" class="w-3.5 h-3.5 accent-blue-600">
                        Header & Border
                    </label>
                </div>
            </div>
        </div>
    </div>

    <div class="quick-access-bar hidden sm:flex shrink-0 no-scrollbar">
        <button onclick="autoSave()" class="hover:bg-gray-300 px-2 py-0.5 rounded text-blue-700"><i class="fa-solid fa-floppy-disk"></i></button>
        <button onclick="execCmd('undo')" class="hover:bg-gray-300 px-2 py-0.5 rounded text-blue-700"><i class="fa-solid fa-rotate-left"></i></button>
        <button onclick="execCmd('redo')" class="hover:bg-gray-300 px-2 py-0.5 rounded text-blue-700"><i class="fa-solid fa-rotate-right"></i></button>
        <div class="w-px h-3 bg-gray-400 mx-1"></div>
        <button onclick="printDocument()" class="hover:bg-gray-300 px-2 py-0.5 rounded text-gray-700 font-bold"><i class="fa-solid fa-print"></i></button>
    </div>

    <div class="workspace workspace-scroll" id="editor-screen">
        <div id="zoomWrapper">
            <div id="document-wrapper"></div>
        </div>
    </div>

    <div class="status-bar shrink-0">
        <div class="flex items-center gap-4">
            <span class="status-item font-bold"><span id="wordCount">0</span> words</span>
            <span class="status-item" onclick="toggleSpellCheck()"><i class="fa-solid fa-spell-check text-green-600 mr-1" id="spellIcon"></i> English</span>
        </div>
        <div class="flex items-center gap-3 ml-auto">
            <div class="flex items-center gap-2 border-l border-gray-300 pl-3">
                <button onclick="setZoomByBtn(0.9)" class="status-item"><i class="fa-solid fa-minus text-[10px]"></i></button>
                <input type="range" id="zoomSlider" min="50" max="250" value="100" class="w-20" oninput="setZoom(this.value)">
                <button onclick="setZoomByBtn(1.1)" class="status-item"><i class="fa-solid fa-plus text-[10px]"></i></button>
                <span id="zoomDisplay" class="status-item font-semibold w-8 text-right">100%</span>
            </div>
        </div>
    </div>

    <div class="mobile-bottom-bar no-scrollbar">
        <button onclick="createNewDocument()" class="m-btn"><i class="fa-solid fa-file-circle-plus"></i></button>
        <button onclick="customCut()" class="m-btn"><i class="fa-solid fa-scissors"></i></button>
        <button onclick="customPaste()" class="m-btn"><i class="fa-solid fa-paste"></i></button>
        <div class="w-px h-6 bg-gray-300 mx-0.5"></div>
        <button onclick="execCmd('undo')" class="m-btn"><i class="fa-solid fa-rotate-left"></i></button>
        <button onclick="execCmd('redo')" class="m-btn"><i class="fa-solid fa-rotate-right"></i></button>
        <div class="w-px h-6 bg-gray-300 mx-0.5"></div>
        <button onclick="applyAutoFix()" class="m-btn text-green-700 shadow-sm"><i class="fa-solid fa-check-double mr-1"></i> Fix</button>
        <button onclick="applyAutoBold()" class="m-btn text-purple-700 shadow-sm"><i class="fa-solid fa-wand-magic-sparkles mr-1"></i> Bold</button>
        <div class="w-px h-6 bg-gray-300 mx-0.5"></div>
        <button onclick="setZoomByBtn(0.8)" class="m-btn"><i class="fa-solid fa-minus"></i></button>
        <button onclick="setZoomByBtn(1.2)" class="m-btn"><i class="fa-solid fa-plus"></i></button>
        <button onclick="fitToScreen()" class="m-btn bg-blue-50 border-blue-200"><i class="fa-solid fa-expand"></i></button>
    </div>

    <div id="historyModal" class="hidden fixed inset-0 bg-black/50 z-[110] flex items-center justify-center p-4">
        <div class="bg-white border border-[#2b579a] shadow-2xl w-full max-w-lg flex flex-col max-h-[85vh]">
            <div class="p-3 bg-[#2b579a] text-white flex justify-between items-center text-sm font-bold">
                <span><i class="fa-solid fa-file-word mr-2"></i> Document Storage</span>
                <button onclick="closeHistoryModal()" class="hover:bg-red-500 px-2 py-1"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="p-3 bg-[#f3f2f1] flex gap-2 border-b border-[#e1dfdd]">
                <input type="text" id="newFileName" placeholder="Document Name..." class="flex-1 p-2 text-sm border outline-none">
                <button onclick="saveNewFile()" class="bg-[#2b579a] text-white px-4 py-1 text-sm hover:bg-blue-800 font-bold">Save As</button>
            </div>
            <div id="historyList" class="p-4 overflow-y-auto flex-1 flex flex-col gap-2 workspace-scroll bg-white"></div>
        </div>
    </div>

    <script>
        let currentZoom = 100;
        let isSpellCheck = true;
        let savedRange = null; 
        let activeEditor = null;
        const wrapper = document.getElementById('document-wrapper');
        let currentBorderStyle = 'border-s1';

        let preAutoFixState = null, isAutoFixActive = false;
        let preAutoBoldState = null, isAutoBoldActive = false;
        let lastAutoAction = null;

        document.execCommand('styleWithCSS', false, true);

        const fontData = {
            eng: [
                {name: 'Times New Roman', clean: 'Times New Roman', font: "'Times New Roman', Times, serif"}, 
                {name: 'Georgia', clean: 'Georgia', font: "Georgia, serif"},
                {name: 'Montserrat', clean: 'Montserrat', font: "'Montserrat', sans-serif"}, 
                {name: 'Poppins', clean: 'Poppins', font: "'Poppins', sans-serif"},
                {name: 'Roboto', clean: 'Roboto', font: "'Roboto', sans-serif"}
            ],
            ben: [
                {name: 'Noto Serif Bengali', clean: 'Noto Serif Bengali', font: "'Noto Serif Bengali', serif"}, 
                {name: 'Noto Sans Bengali', clean: 'Noto Sans Bengali', font: "'Noto Sans Bengali', sans-serif"},
                {name: 'Hind Siliguri', clean: 'Hind Siliguri', font: "'Hind Siliguri', sans-serif"}, 
                {name: 'Baloo Da 2', clean: 'Baloo Da 2', font: "'Baloo Da 2', cursive"}
            ],
            hand: [
                {name: 'Caveat', clean: 'Caveat', font: "'Caveat', cursive"}, 
                {name: 'Kalam', clean: 'Kalam', font: "'Kalam', cursive"},
                {name: 'Dancing Script', clean: 'Dancing Script', font: "'Dancing Script', cursive"}
            ],
            mixed: [
                {name: 'Modern Sans', clean: 'Roboto', font: "'Roboto', 'Noto Sans Bengali', sans-serif"},
                {name: 'Handwritten Mix', clean: 'Caveat', font: "'Caveat', 'Atma', cursive"}
            ]
        };

        const standardSizes = [8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48];

        window.addEventListener('load', () => {
            if (wrapper.children.length === 0) wrapper.appendChild(createNewPage(true));
            const sizeMenu = document.getElementById('globalFontSizeMenu');
            sizeMenu.innerHTML = standardSizes.map(s => `<div onclick="applyFontSizeVal(${s})" class="px-3 py-1.5 hover:bg-gray-100 cursor-pointer border-b text-center">${s}</div>`).join('');
            switchFontTab('eng', document.querySelector('.font-tab'));

            const saved = localStorage.getItem('wordProCurrentDoc');
            if(saved) { document.querySelector('.page-content').innerHTML = saved; queuePaginate(); }
            if(window.innerWidth <= 768) setTimeout(fitToScreen, 100);
            updateContent();
        });

        document.addEventListener('click', (e) => {
            if(!e.target.closest('#fontBtnDisplay') && !e.target.closest('#globalFontMegaMenu')) document.getElementById('globalFontMegaMenu').classList.add('hidden');
            if(!e.target.closest('#fontSizeDisplay') && !e.target.closest('#globalFontSizeMenu')) document.getElementById('globalFontSizeMenu').classList.add('hidden');
        });

        function toggleFontMenu(btn) {
            saveSelection();
            const menu = document.getElementById('globalFontMegaMenu');
            const rect = btn.getBoundingClientRect();
            menu.style.top = (rect.bottom + 2) + 'px';
            menu.style.left = Math.max(10, rect.left) + 'px'; 
            menu.classList.toggle('hidden');
            document.getElementById('globalFontSizeMenu').classList.add('hidden');
        }

        function toggleFontSizeMenu(btn) {
            saveSelection();
            const menu = document.getElementById('globalFontSizeMenu');
            const rect = btn.getBoundingClientRect();
            menu.style.top = (rect.bottom + 2) + 'px';
            menu.style.left = rect.left + 'px';
            menu.classList.toggle('hidden');
            document.getElementById('globalFontMegaMenu').classList.add('hidden');
        }

        function switchFontTab(tabId, btnElement) {
            document.querySelectorAll('.font-tab').forEach(t => t.classList.remove('border-blue-600', 'text-blue-600'));
            document.querySelectorAll('.font-tab').forEach(t => t.classList.add('border-transparent', 'text-gray-600'));
            if(btnElement) {
                btnElement.classList.remove('border-transparent', 'text-gray-600');
                btnElement.classList.add('border-blue-600', 'text-blue-600');
            }

            const content = document.getElementById('fontTabContent');
            const sampleText = 'The quick brown fox jumps over the lazy dog';
            
            content.innerHTML = fontData[tabId].map(f => `
                <div onclick="applyFontName('${f.clean}', '${f.font}', '${f.name}')" class="p-2 hover:bg-blue-50 cursor-pointer border-b border-gray-100 flex flex-col group">
                    <span class="text-[10px] text-gray-400 group-hover:text-blue-600 font-sans mb-1 uppercase tracking-wider">${f.name}</span>
                    <span style="font-family: ${f.font}; font-size: 16px; color: #1f2937;" class="truncate">${sampleText}</span>
                </div>
            `).join('');
        }

        function applyFontName(cleanName, fullStack, shortName) {
            restoreSelection(); 
            const sel = window.getSelection();
            if (!sel.rangeCount || sel.isCollapsed) {
                document.querySelectorAll('.page-content').forEach(page => {
                    page.style.fontFamily = fullStack;
                    page.querySelectorAll('*').forEach(el => el.style.fontFamily = fullStack);
                });
            } else {
                document.execCommand('fontName', false, cleanName);
            }
            document.getElementById('currentFontDisplay').innerText = shortName.split(' ')[0];
            document.getElementById('globalFontMegaMenu').classList.add('hidden');
            if(activeEditor) activeEditor.focus();
            updateContent(); queuePaginate();
        }

        function applyFontSizeVal(sizePx) {
            restoreSelection(); 
            document.querySelectorAll('.page-content').forEach(page => {
                page.style.fontSize = sizePx + 'px';
            });
            document.getElementById('currentFontSize').innerText = sizePx;
            document.getElementById('globalFontSizeMenu').classList.add('hidden');
            if(activeEditor) activeEditor.focus();
            updateContent(); queuePaginate();
        }

        function changeFontSizeBy(dir) {
            let current = parseInt(document.getElementById('currentFontSize').innerText) || 16;
            let index = standardSizes.indexOf(current);
            let newIndex = Math.max(0, Math.min(standardSizes.length - 1, index + dir));
            saveSelection();
            applyFontSizeVal(standardSizes[newIndex]);
        }

        function showModal(title, message, type, defaultVal, callback) {
            const modal = document.getElementById('customModal');
            document.getElementById('modalTitle').innerHTML = `<i class="fa-solid fa-circle-info"></i> ${title}`;
            document.getElementById('modalMessage').textContent = message;
            const input = document.getElementById('modalInput');
            
            if (type === 'prompt') {
                input.classList.remove('hidden'); input.value = defaultVal || ''; setTimeout(() => input.focus(), 100);
            } else { input.classList.add('hidden'); }
            
            modal.classList.remove('hidden');
            const handleOk = () => { cleanup(); callback(type === 'prompt' ? input.value : true); };
            const handleCancel = () => { cleanup(); if (type === 'prompt') callback(null); else callback(false); };
            const cleanup = () => {
                modal.classList.add('hidden');
                document.getElementById('modalOk').removeEventListener('click', handleOk);
                document.getElementById('modalCancel').removeEventListener('click', handleCancel);
            };
            document.getElementById('modalOk').addEventListener('click', handleOk);
            document.getElementById('modalCancel').addEventListener('click', handleCancel);
        }
        function customPrompt(title, message, defaultVal, callback) { showModal(title, message, 'prompt', defaultVal, callback); }
        function customConfirm(title, message, callback) { showModal(title, message, 'confirm', null, callback); }

        function saveSelection() {
            if (window.getSelection) {
                const sel = window.getSelection();
                if (sel.getRangeAt && sel.rangeCount) savedRange = sel.getRangeAt(0);
            }
        }
        function restoreSelection() {
            if (savedRange && window.getSelection) {
                const sel = window.getSelection();
                sel.removeAllRanges(); sel.addRange(savedRange);
            }
        }

        function applyColor(cmd, value) {
            restoreSelection();
            document.execCommand(cmd, false, value);
            if(activeEditor) activeEditor.focus();
            updateContent(); queuePaginate();
        }

        async function customPaste() {
            try {
                const text = await navigator.clipboard.readText();
                restoreSelection();
                document.execCommand('insertText', false, text);
                if(activeEditor) activeEditor.focus();
                updateContent(); queuePaginate();
            } catch (err) {
                showToast("Please use standard Paste");
            }
        }
        
        function customCut() {
            restoreSelection();
            document.execCommand('cut');
            updateContent(); queuePaginate();
            showToast("Cut to clipboard");
        }

        let isPaginating = false;
        let paginationTimeout;

        function createNewPage(isFirst = false) {
            const page = document.createElement('div');
            page.className = 'page';
            
            page.innerHTML = `
                <div class="page-border-layer ${currentBorderStyle}">
                    <div class="pb-tl corner"></div><div class="pb-tr corner"></div><div class="pb-bl corner"></div><div class="pb-br corner"></div>
                    <div class="pb-text pb-top">
                        <span><i class="fa-solid fa-house" style="color:#d97706;"></i> STUDY POINT</span>
                        <span style="color: black;"><i class="fa-solid fa-book-open" style="color: #dc2626;"></i> NOTE</span>
                        <span><i class="fa-solid fa-pencil"></i> PRO</span>
                    </div>
                </div>
                <div class="page-content" contenteditable="true" data-placeholder="Type your content here..." spellcheck="${isSpellCheck}" style="font-size: 16px;"></div>
                <div class="page-footer text-center text-xs opacity-40 italic">Page</div>
            `;
            return page;
        }

        function toggleDecorations(isVisible) {
            if (isVisible) {
                document.body.classList.remove('hide-decorations');
                showToast("Decorations Enabled");
            } else {
                document.body.classList.add('hide-decorations');
                showToast("Decorations Disabled");
            }
        }

        function changeBorderStyle(styleClass) {
            currentBorderStyle = styleClass;
            document.querySelectorAll('.page-border-layer').forEach(layer => layer.className = `page-border-layer ${styleClass}`);
            showToast("Border Style Updated");
        }

        function paginate() {
            if (isPaginating) return;
            isPaginating = true;
            let pages = wrapper.querySelectorAll('.page');
            for (let i = 0; i < pages.length; i++) {
                let pageContent = pages[i].querySelector('.page-content');
                if (pageContent.scrollHeight > pageContent.clientHeight) {
                    let nextPage = pages[i + 1];
                    if (!nextPage) { nextPage = createNewPage(); wrapper.appendChild(nextPage); }
                }
            }
            isPaginating = false;
        }

        function queuePaginate() { clearTimeout(paginationTimeout); paginationTimeout = setTimeout(paginate, 150); }

        wrapper.addEventListener('input', (e) => {
            if (e.target.classList.contains('page-content')) { updateContent(); queuePaginate(); }
        });

        wrapper.addEventListener('focusin', (e) => { if (e.target.classList.contains('page-content')) activeEditor = e.target; });

        function switchTab(tabElement, tabId) {
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.ribbon-groups').forEach(content => content.classList.remove('active'));
            tabElement.classList.add('active'); document.getElementById(tabId).classList.add('active');
        }

        const workspaceEl = document.getElementById('editor-screen');
        function setZoomByBtn(factor) { setZoom(Math.round(currentZoom * factor)); }
        function setZoom(val) {
            currentZoom = Math.max(30, Math.min(250, parseInt(val)));
            document.getElementById('zoomWrapper').style.transform = `scale(${currentZoom / 100})`;
            document.getElementById('zoomDisplay').innerText = currentZoom + '%';
            document.getElementById('zoomSlider').value = currentZoom;
        }

        function fitToScreen() {
            const screenWidth = workspaceEl.clientWidth, editorWidth = wrapper.offsetWidth || 794; 
            setZoom(Math.floor(((screenWidth - 20) / editorWidth) * 100)); showToast("Fit to Screen Applied");
        }

        function changeColumns(val) {
            document.querySelectorAll('.page-content').forEach(p => {
                p.style.columnCount = val; p.style.columnGap = '10mm'; p.style.columnRule = val > 1 ? '1px solid #cbd5e1' : 'none';
            });
            showToast(`${val} Column(s) Applied`);
        }

        function insertTable() {
            customPrompt('Insert Table', 'Rows:', '3', (rows) => {
                if (!rows) return;
                customPrompt('Insert Table', 'Columns:', '3', (cols) => {
                    if (!cols) return;
                    let html = `<br><table style="width:100%; border-collapse:collapse; margin:10px 0;"><tbody>`;
                    for(let r=0; r<rows; r++) { html += `<tr>`; for(let c=0; c<cols; c++) html += `<td style="border:1px solid #999; padding:5px;">Cell</td>`; html += `</tr>`; }
                    html += `</tbody></table><br>`;
                    execCmd('insertHTML', html);
                });
            });
        }
        
        function insertLink() { customPrompt('Insert Link', 'Enter URL:', 'https://', (url) => { if (url) execCmd('createLink', url); }); }
        function insertImage(input) { if (input.files && input.files[0]) { const reader = new FileReader(); reader.onload = function(e) { execCmd('insertHTML', `<img src="${e.target.result}" style="max-width:100%; height:auto;" />`); }; reader.readAsDataURL(input.files[0]); } }

        function toggleSpellCheck() { isSpellCheck = !isSpellCheck; document.querySelectorAll('.page-content').forEach(p => p.setAttribute('spellcheck', isSpellCheck)); }
        function toggleShareDropdown() { document.getElementById('shareDropdown').classList.toggle('hidden'); }

        function showToast(message) {
            const toast = document.getElementById('toast'); document.getElementById('toastMessage').textContent = message;
            toast.classList.remove('opacity-0'); setTimeout(() => toast.classList.add('opacity-0'), 2500);
        }

        function execCmd(cmd, value=null) {
            document.execCommand(cmd, false, value);
            if (activeEditor) activeEditor.focus();
            updateContent(); queuePaginate();
        }
        
        function createNewDocument() {
            customConfirm('New Document', 'Clear current document?', (yes) => {
                if(yes) {
                    wrapper.innerHTML = ''; wrapper.appendChild(createNewPage(true));
                    localStorage.removeItem('wordProCurrentDoc');
                    updateContent(); showToast("New Document Created!");
                }
            });
        }

        function changeLineSpacing(level) {
            document.querySelectorAll('.page-content').forEach(p => { p.className = p.className.replace(/l-spacing-\d+/g, ''); p.classList.add(`l-spacing-${level}`); });
            updateContent();
        }

        function getFullHTML() { return Array.from(document.querySelectorAll('.page-content')).map(p => p.innerHTML).join('<br>'); }
        function getFullText() { return Array.from(document.querySelectorAll('.page-content')).map(p => p.innerText).join('\n'); }

        function autoSave() { localStorage.setItem('wordProCurrentDoc', getFullHTML()); } setInterval(autoSave, 30000); 

        function openHistoryModal() { renderHistoryList(); document.getElementById('historyModal').classList.remove('hidden'); }
        function closeHistoryModal() { document.getElementById('historyModal').classList.add('hidden'); }
        
        function saveNewFile() {
            const name = document.getElementById('newFileName').value || 'Document1';
            let histories = JSON.parse(localStorage.getItem('wordProHistories') || '[]');
            histories.unshift({ id: Date.now(), title: name, date: new Date().toLocaleString(), content: getFullHTML() });
            localStorage.setItem('wordProHistories', JSON.stringify(histories));
            document.getElementById('newFileName').value = ''; renderHistoryList(); showToast("Saved");
        }

        function renderHistoryList() {
            const list = document.getElementById('historyList'); let histories = JSON.parse(localStorage.getItem('wordProHistories') || '[]');
            if(histories.length === 0) { list.innerHTML = `<div class="text-center text-gray-500 py-4 text-sm">No saved files.</div>`; return; }
            list.innerHTML = histories.map(item => `
                <div class="border border-gray-300 p-2 flex justify-between items-center hover:bg-gray-50 cursor-pointer">
                    <div onclick="loadHistory(${item.id})" class="flex-1"><p class="font-semibold text-sm text-[#2b579a]">${item.title}</p><p class="text-[10px] text-gray-500">${item.date}</p></div>
                    <button onclick="deleteHistory(${item.id})" class="px-2 py-1 text-red-500 hover:bg-red-100 rounded text-xs"><i class="fa-solid fa-trash"></i></button>
                </div>
            `).join('');
        }

        function loadHistory(id) {
            let histories = JSON.parse(localStorage.getItem('wordProHistories') || '[]');
            const history = histories.find(h => h.id === id);
            if(history) { 
                wrapper.innerHTML = ''; wrapper.appendChild(createNewPage(true));
                document.querySelector('.page-content').innerHTML = history.content; 
                updateContent(); closeHistoryModal(); showToast("Opened"); 
            }
        }
        function deleteHistory(id) {
            let histories = JSON.parse(localStorage.getItem('wordProHistories') || '[]');
            localStorage.setItem('wordProHistories', JSON.stringify(histories.filter(h => h.id !== id))); renderHistoryList();
        }

        function applyAutoFix() {
            let fullHTML = getFullHTML(); if (!fullHTML.trim()) return;
            let cleaned = fullHTML.replace(/[ \t]{2,}/g, ' ').replace(/(<br\s*\/?>\s*){2,}/gi, '<br>');
            wrapper.innerHTML = ''; wrapper.appendChild(createNewPage(true));
            document.querySelector('.page-content').innerHTML = cleaned;
            updateContent(); showToast("AutoFix Complete");
        }

        function applyAutoBold() {
            let fullHTML = getFullHTML(); if (!fullHTML.trim()) return;
            document.querySelectorAll('.page-content').forEach(page => {
                let textNodes = [];
                let walker = document.createTreeWalker(page, NodeFilter.SHOW_TEXT, null, false);
                let node;
                while(node = walker.nextNode()) if (node.nodeValue.includes('?')) textNodes.push(node);
                textNodes.forEach(t => {
                    let span = document.createElement('span');
                    span.innerHTML = t.nodeValue.replace(/([^.!?\n]+[?？])/g, '<b>$1</b>');
                    t.parentNode.replaceChild(span, t);
                });
            });
            updateContent(); showToast("Auto Bold Applied");
        }

        function updateContent() { let text = getFullText(); document.getElementById('wordCount').innerText = text.trim() ? text.trim().split(/\s+/).length : 0; }

        function downloadTxt() {
            document.getElementById('shareDropdown').classList.add('hidden');
            const fileDownload = document.createElement("a");
            fileDownload.href = 'data:text/plain;charset=utf-8,' + encodeURIComponent(getFullText()); fileDownload.download = 'Document.txt';
            document.body.appendChild(fileDownload); fileDownload.click(); document.body.removeChild(fileDownload); showToast("Text file exported");
        }
        
        function exportPDF() {
            document.getElementById('shareDropdown').classList.add('hidden'); showToast("Generating PDF...");
            const opt = {
                margin: 0, filename: 'WordPro_Document.pdf', image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true }, jsPDF: { unit: 'px', format: [794, 1123], orientation: 'portrait' }
            };
            html2pdf().set(opt).from(wrapper).save().then(() => showToast("PDF Exported successfully!")).catch(() => showToast("Error generating PDF."));
        }

        function printDocument() {
            window.print();
        }
    </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2b579a),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                useHybridComposition: true,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                allowFileAccess: true,
                allowContentAccess: true,
                builtInZoomControls: true,
                displayZoomControls: false,
                supportZoom: true,
                transparentBackground: false,
              ),
              initialData: InAppWebViewInitialData(
                data: editorHtmlContent,
                mimeType: 'text/html',
                encoding: 'utf-8',
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
