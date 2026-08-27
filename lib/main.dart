import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
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
        
        .r-btn { background: transparent; border: 1px solid transparent; border-radius: 2px; padding: 3px 5px; cursor: pointer; display: inline-flex; flex-direction: column; align-items: center; justify-content: center; font-size: 13px; color: #3b3a39;}
        .r-btn:hover { background-color: var(--word-hover); border-color: #c8c6c4; }
        .r-btn-small { padding: 3px; font-size: 12px; display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; }
        .r-select { border: 1px solid #8a8886; font-size: 12px; padding: 2px; outline: none; background: white;}

        .quick-access-bar { background-color: var(--word-bg); border-bottom: 1px solid #d1d5db; display: flex; align-items: center; padding: 2px 10px; gap: 8px; font-size: 12px; color: #3b3a39; overflow-x: auto; flex-shrink: 0; z-index: 50;}
        .status-bar { background-color: var(--word-bg); border-top: 1px solid var(--word-border); color: #3b3a39; font-size: 11px; display: flex; justify-content: space-between; align-items: center; padding: 2px 15px; flex-shrink: 0; white-space: nowrap; overflow-x: auto; gap: 10px; z-index: 50;}
        .status-item { cursor: pointer; padding: 2px 5px; }

        .mobile-bottom-bar { display: none; background-color: #ffffff; border-top: 1px solid #d1d5db; padding: 8px 10px; justify-content: flex-start; align-items: center; flex-shrink: 0; overflow-x: auto; gap: 8px; box-shadow: 0 -2px 10px rgba(0,0,0,0.05); z-index: 50;}
        .m-btn { background: #f3f2f1; border: 1px solid #e1dfdd; border-radius: 6px; padding: 8px 14px; font-size: 16px; color: var(--word-blue); display: inline-flex; align-items: center; justify-content: center; font-weight: bold; flex-shrink: 0;}

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
        .pb-bottom { bottom: 0; left: 50%; transform: translate(-50%, 50%); font-size: 11px; padding: 0 15px;}
        .pb-left { left: 0; top: 50%; transform: translate(-50%, -50%) rotate(-90deg); font-size: 9px; padding: 0 10px; white-space: nowrap;}
        .pb-right { right: 0; top: 50%; transform: translate(50%, -50%) rotate(90deg); font-size: 9px; padding: 0 10px; white-space: nowrap;}

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

        .page-content { flex: 1; outline: none; overflow-y: hidden; word-wrap: break-word; line-height: 1.6; font-size: 16px; text-align: left; margin-bottom: 25px; position: relative; z-index: 20; }
        .page-content:empty:before { content: attr(data-placeholder); color: #9ca3af; pointer-events: none; }
        .page-content table { width: 100%; border-collapse: collapse; margin-bottom: 1em; }
        .page-content table, .page-content th, .page-content td { border: 1px solid #94a3b8; padding: 8px; }

        .page-footer { height: 30px; display: flex; justify-content: center; align-items: center; color: #9ca3af; font-size: 12px; border-top: 1px dashed transparent; user-select: none; position: absolute; bottom: 15px; left: 0; width: 100%; z-index: 20; }
    </style>
</head>
<body>
    <div id="toast" class="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-gray-900/95 text-white px-6 py-3 rounded shadow-2xl transition-all duration-300 opacity-0 pointer-events-none z-[200] flex items-center gap-2 font-bold text-sm tracking-wide">
        <i class="fa-solid fa-circle-info text-blue-400"></i> <span id="toastMessage"></span>
    </div>

    <div class="title-bar">
        <div class="flex items-center gap-4 w-1/3">
            <button onclick="autoSave()" class="hover:bg-white/20 px-2 py-1 rounded" title="Save"><i class="fa-regular fa-floppy-disk"></i></button>
        </div>
        <div class="text-center w-1/3 flex justify-center items-center gap-2 font-semibold tracking-wide bg-blue-800/50 rounded px-4 py-0.5 truncate">
            Word Pro
        </div>
        <div class="flex justify-end items-center gap-3 w-1/3 text-sm">
            <button onclick="window.print()" class="hover:bg-white/20 px-2 py-1"><i class="fa-solid fa-print"></i></button>
        </div>
    </div>

    <div class="tabs-bar no-scrollbar">
        <div class="tab-btn active" onclick="switchTab(this, 'tab-home')">Home</div>
        <div class="tab-btn" onclick="switchTab(this, 'tab-insert')">Insert</div>
        <div class="tab-btn" onclick="switchTab(this, 'tab-layout')">Layout</div>
        <div class="tab-btn ml-auto bg-blue-800 rounded px-3" onclick="exportPDF()">
            <i class="fa-solid fa-file-pdf"></i> Export PDF
        </div>
    </div>

    <div class="ribbon-area">
        <div id="tab-home" class="ribbon-groups active no-scrollbar">
            <div class="r-group">
                <div class="flex gap-1 h-full items-center">
                    <button onclick="window.print()" class="r-btn" style="height:100%">
                        <i class="fa-solid fa-print text-[22px] text-blue-700 mb-1"></i>
                        <span class="text-[11px] font-bold">Print</span>
                    </button>
                    <div class="flex flex-col gap-0.5 justify-center">
                        <button onclick="createNewDocument()" class="r-btn r-btn-small" title="New"><i class="fa-solid fa-file-circle-plus text-green-600"></i></button>
                        <button onclick="execCmd('undo')" class="r-btn r-btn-small" title="Undo"><i class="fa-solid fa-rotate-left"></i></button>
                    </div>
                </div>
            </div>

            <div class="r-group">
                <div class="flex gap-1 mb-1">
                    <button onmousedown="event.preventDefault();" onclick="execCmd('bold')" class="r-btn r-btn-small font-bold">B</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('italic')" class="r-btn r-btn-small italic font-serif">I</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('underline')" class="r-btn r-btn-small underline">U</button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('strikeThrough')" class="r-btn r-btn-small line-through">ab</button>
                </div>
                <div class="flex gap-0.5">
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyLeft')" class="r-btn r-btn-small"><i class="fa-solid fa-align-left"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyCenter')" class="r-btn r-btn-small"><i class="fa-solid fa-align-center"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyRight')" class="r-btn r-btn-small"><i class="fa-solid fa-align-right"></i></button>
                    <button onmousedown="event.preventDefault();" onclick="execCmd('justifyFull')" class="r-btn r-btn-small"><i class="fa-solid fa-align-justify"></i></button>
                </div>
            </div>

            <div class="r-group">
                <div class="flex gap-1 h-full items-center px-2">
                    <button onclick="applyAutoBold()" class="r-btn text-purple-700 font-bold border border-purple-200 bg-purple-50 shadow-sm" style="height: 100%">
                        <i class="fa-solid fa-wand-magic-sparkles text-lg"></i><span>Auto Bold</span>
                    </button>
                    <button onclick="applyAutoFix()" class="r-btn text-green-700 font-bold border border-green-200 bg-green-50 shadow-sm" style="height: 100%">
                        <i class="fa-solid fa-check-double text-lg"></i><span>AutoFix</span>
                    </button>
                </div>
            </div>
        </div>

        <div id="tab-insert" class="ribbon-groups no-scrollbar">
            <div class="r-group"><div class="flex gap-1 h-full"><button onclick="execCmd('insertHorizontalRule')" class="r-btn h-full"><i class="fa-solid fa-file-lines text-xl text-blue-500 mb-1"></i><span class="text-[11px]">Break</span></button><button onclick="insertTable()" class="r-btn h-full"><i class="fa-solid fa-table text-xl text-orange-600 mb-1"></i><span class="text-[11px]">Table</span></button></div></div>
        </div>

        <div id="tab-layout" class="ribbon-groups no-scrollbar">
            <div class="r-group bg-blue-50/50">
                <div class="flex flex-col gap-1 px-1 justify-center h-full">
                    <span class="text-[11px] font-bold text-blue-800">Border:</span>
                    <select onchange="changeBorderStyle(this.value)" class="r-select w-32 font-semibold">
                        <option value="border-none">None</option>
                        <option value="border-s1" selected>Style 1</option>
                        <option value="border-s2">Style 2 (Blue)</option>
                        <option value="border-s3">Style 3 (Solid)</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="workspace workspace-scroll" id="editor-screen">
        <div id="zoomWrapper">
            <div id="document-wrapper"></div>
        </div>
    </div>

    <div class="mobile-bottom-bar no-scrollbar">
        <button onclick="createNewDocument()" class="m-btn"><i class="fa-solid fa-file-circle-plus"></i></button>
        <button onclick="execCmd('undo')" class="m-btn"><i class="fa-solid fa-rotate-left"></i></button>
        <button onclick="execCmd('redo')" class="m-btn"><i class="fa-solid fa-rotate-right"></i></button>
        <button onclick="applyAutoFix()" class="m-btn text-green-700"><i class="fa-solid fa-check-double mr-1"></i> Fix</button>
        <button onclick="applyAutoBold()" class="m-btn text-purple-700"><i class="fa-solid fa-wand-magic-sparkles mr-1"></i> Bold</button>
        <button onclick="fitToScreen()" class="m-btn bg-blue-50"><i class="fa-solid fa-expand"></i></button>
    </div>

    <script>
        let currentZoom = 100;
        let activeEditor = null;
        const wrapper = document.getElementById('document-wrapper');
        let currentBorderStyle = 'border-s1';

        window.addEventListener('load', () => {
            if (wrapper.children.length === 0) wrapper.appendChild(createNewPage(true));
            const saved = localStorage.getItem('wordProCurrentDoc');
            if(saved) document.querySelector('.page-content').innerHTML = saved;
            if(window.innerWidth <= 768) setTimeout(fitToScreen, 100);
        });

        function createNewPage(isFirst = false) {
            const page = document.createElement('div');
            page.className = 'page';
            page.innerHTML = `
                <div class="page-border-layer ${currentBorderStyle}">
                    <div class="pb-tl corner"></div><div class="pb-tr corner"></div><div class="pb-bl corner"></div><div class="pb-br corner"></div>
                    <div class="pb-text pb-top"><span>STUDY POINT</span><span>ENGLISH</span><span>PRO</span></div>
                </div>
                <div class="page-content" contenteditable="true" data-placeholder="Type your content here..." style="font-size: 16px;"></div>
                <div class="page-footer text-center text-xs opacity-40 italic">Page</div>
            `;
            return page;
        }

        function changeBorderStyle(styleClass) {
            currentBorderStyle = styleClass;
            document.querySelectorAll('.page-border-layer').forEach(layer => layer.className = `page-border-layer ${styleClass}`);
            showToast("Border Updated");
        }

        wrapper.addEventListener('focusin', (e) => { if (e.target.classList.contains('page-content')) activeEditor = e.target; });

        function switchTab(tabElement, tabId) {
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.ribbon-groups').forEach(content => content.classList.remove('active'));
            tabElement.classList.add('active'); document.getElementById(tabId).classList.add('active');
        }

        function setZoom(val) {
            currentZoom = Math.max(30, Math.min(250, parseInt(val)));
            document.getElementById('zoomWrapper').style.transform = `scale(${currentZoom / 100})`;
        }

        function fitToScreen() {
            const screenWidth = document.getElementById('editor-screen').clientWidth;
            setZoom(Math.floor(((screenWidth - 20) / 794) * 100));
            showToast("Fit to Screen");
        }

        function insertTable() {
            let html = `<br><table style="width:100%; border-collapse:collapse; margin:10px 0;"><tbody>`;
            for(let r=0; r<3; r++) { html += `<tr>`; for(let c=0; c<3; c++) html += `<td style="border:1px solid #999; padding:5px;">Cell</td>`; html += `</tr>`; }
            html += `</tbody></table><br>`;
            execCmd('insertHTML', html);
        }

        function showToast(message) {
            const toast = document.getElementById('toast'); document.getElementById('toastMessage').textContent = message;
            toast.classList.remove('opacity-0'); setTimeout(() => toast.classList.add('opacity-0'), 2500);
        }

        function execCmd(cmd, value=null) {
            document.execCommand(cmd, false, value);
            if (activeEditor) activeEditor.focus();
        }
        
        function createNewDocument() {
            wrapper.innerHTML = ''; wrapper.appendChild(createNewPage(true));
            localStorage.removeItem('wordProCurrentDoc');
            showToast("New Document Created!");
        }

        function getFullHTML() { return Array.from(document.querySelectorAll('.page-content')).map(p => p.innerHTML).join('<br>'); }
        function autoSave() { localStorage.setItem('wordProCurrentDoc', getFullHTML()); showToast("Saved"); }

        function applyAutoFix() {
            let fullHTML = getFullHTML(); if (!fullHTML.trim()) return;
            let cleaned = fullHTML.replace(/[ \t]{2,}/g, ' ').replace(/(<br\s*\/?>\s*){2,}/gi, '<br>');
            wrapper.innerHTML = ''; wrapper.appendChild(createNewPage(true));
            document.querySelector('.page-content').innerHTML = cleaned;
            showToast("AutoFix Complete");
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
            showToast("Auto Bold Applied");
        }

        function exportPDF() {
            showToast("Generating PDF...");
            const opt = {
                margin: 0, filename: 'WordPro_Document.pdf', image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true }, jsPDF: { unit: 'px', format: [794, 1123], orientation: 'portrait' }
            };
            html2pdf().set(opt).from(wrapper).save().then(() => showToast("PDF Exported!")).catch(() => showToast("Error generating PDF."));
        }
    </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF2b579a))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(editorHtmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2b579a),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
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
