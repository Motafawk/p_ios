import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:motafawk/controller/download_files_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import '../vars.dart' as v;
import '../funs.dart' as f;

class MySFPdf extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  const MySFPdf({Key? key, required this.fileUrl, required this.fileName}) : super(key: key);

  @override
  State<MySFPdf> createState() => _MySFPdfState();
}

class _MySFPdfState extends State<MySFPdf> {
  PageNumberController pageNumberController = Get.put(PageNumberController());
  DownloadFilesController downloadFilesController = Get.put(DownloadFilesController());

  PdfViewerController pdfViewerController = PdfViewerController();
  TextEditingController _txtpagenumber = TextEditingController();

  bool isFirstPage = true;
  bool isLastPage = false;

  OverlayEntry? _overlayEntry;
  void _showContextMenu(BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState? _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 56,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 10,
          ),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: details.selectedText??""));
            pdfViewerController.clearSelection();
          },
          child: Text('Copy', style: TextStyle(fontSize: 17)),
        ),
      ),
    );
    _overlayState!.insert(_overlayEntry!);
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          title: Text(
            "${widget.fileName}",
            style: TextStyle(fontSize: 14),
          ),
          elevation: 2,
          titleSpacing: -8,
        ),
      ),
      body: FutureBuilder(
        future: DefaultCacheManager().getSingleFile(widget.fileUrl),
        builder: (context, AsyncSnapshot<File?> snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data!.length == 0){
              return Center(
                child: Text("لا توجد ملفات تم تنزيلها"),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SfPdfViewer.file(
                    snapshot.data!,
                    controller: pdfViewerController,
                    pageSpacing: 8,
                    enableDocumentLinkAnnotation: false,
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      print("details.document.pages.count: ${details.document.pages.count}");
                      _txtpagenumber.text = "${pdfViewerController.pageNumber}";
                      pageNumberController.update();
                    },
                    onPageChanged: (PdfPageChangedDetails details) {
                      print("PdfPageChangedDetails: ${details.newPageNumber}");
                      _txtpagenumber.text = "${pdfViewerController.pageNumber}";
                      isFirstPage = details.isFirstPage;
                      isLastPage = details.isLastPage;
                      pageNumberController.update();
                    },
                    onHyperlinkClicked: (PdfHyperlinkClickedDetails pdfHyperlinkClickedDetails) {
                      print(pdfHyperlinkClickedDetails.uri);
                    },
                    canShowHyperlinkDialog: false,
                    onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                      if (details.selectedText == null && _overlayEntry != null) {
                        _overlayEntry!.remove();
                        _overlayEntry = null;
                      } else if (details.selectedText != null && _overlayEntry == null) {
                        _showContextMenu(context, details);
                      }
                    },
                  ),
                ),
                Material(
                  color: Colors.grey[300],
                  child: Container(
                    width: w,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, -1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Printing.layoutPdf(
                                name: "حل كتاب الرياضيات طباعة",
                                format: PdfPageFormat.a4,
                                dynamicLayout: true,
                                usePrinterSettings: true,
                                onLayout: (PdfPageFormat format) async {
                                  Uint8List bytes = snapshot.data!.readAsBytesSync();
                                  return bytes;
                                });
                          },
                          icon: Icon(Icons.print_outlined),
                        ),
                        Expanded(
                          child: GetBuilder<PageNumberController>(builder: (controller) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isFirstPage == false)
                                  InkWell(
                                    onTap: () {
                                      pdfViewerController.jumpToPage(1);
                                    },
                                    child: Icon(Icons.keyboard_double_arrow_right),
                                  ),
                                if (isFirstPage == false)
                                  InkWell(
                                    onTap: () {
                                      pdfViewerController.previousPage();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.arrow_back_ios_rounded),
                                    ),
                                  ),
                                Container(
                                  width: 40,
                                  height: 25,
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 14),
                                    controller: _txtpagenumber,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Text(
                                  " / ",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text("${pdfViewerController.pageCount}"),
                                if (isLastPage == false)
                                  InkWell(
                                    onTap: () {
                                      pdfViewerController.nextPage();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                  ),
                                if (isLastPage == false)
                                  InkWell(
                                    onTap: () {
                                      pdfViewerController.jumpToPage(pdfViewerController.pageCount);
                                    },
                                    child: Icon(Icons.keyboard_double_arrow_left),
                                  ),
                              ],
                            );
                          }),
                        ),

                        GetBuilder<DownloadFilesController>(
                          builder: (controller) {
                            return FutureBuilder(
                              future: FlutterDownloader.loadTasksWithRawQuery(
                                query: "select * from task where url = '${widget.fileUrl}' order by time_created desc;",
                              ),
                              builder: (context, AsyncSnapshot<List<DownloadTask>?> snapshot) {
                                if (snapshot.hasData) {
                                  File file = File("${v.downloadPath}/${widget.fileName}.pdf");
                                  if (snapshot.data!.length == 0) {
                                    print("file path: ${v.downloadPath}/${widget.fileName}.pdf");
                                    return IconButton(
                                      onPressed: () async {
                                        if (file.existsSync()) {
                                          Get.defaultDialog(
                                            titlePadding: EdgeInsets.zero,
                                            title: "",
                                            contentPadding: EdgeInsets.zero,
                                            content: Column(
                                              children: [
                                                Text("The ${widget.fileName}.pdf file is already exist. Is want replace? "),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        file.deleteSync();
                                                        f.downloadFile(widget.fileUrl, "${widget.fileName}");
                                                        Get.back();
                                                      },
                                                      child: Text("Yes"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text("No"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        else {
                                          f.downloadFile(widget.fileUrl, "${widget.fileName}");
                                        }
                                      },
                                      icon: Icon(Icons.download),
                                    );
                                  }
                                  else {
                                    final DownloadTask item = snapshot.data![0];
                                    DownloadTaskStatus status = item.status;

                                    if (status == DownloadTaskStatus.complete && file.existsSync()) {
                                      return IconButton(
                                        onPressed: () async {
                                          if (status == DownloadTaskStatus.complete && !file.existsSync()) {
                                            print("The file there is not exist in download folder!: ${item}");
                                            await Fluttertoast.showToast(
                                              msg: "The file there is not exist in download folder!",
                                              backgroundColor: Colors.amber,
                                              textColor: Colors.black,
                                            );
                                            await FlutterDownloader.loadTasksWithRawQuery(
                                              query: "delete from task where url = '${widget.fileUrl}';",
                                            );
                                            print("deleted the '${widget.fileUrl}' from db");
                                            // controller.update();
                                            f.downloadFile(widget.fileUrl, "${widget.fileName}");
                                          } else {
                                            await FlutterDownloader.open(taskId: item.taskId);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.verified_outlined,
                                          color: Colors.green,
                                        ),
                                      );
                                    }
                                    else if (status == DownloadTaskStatus.running) {
                                      return IconButton(
                                        onPressed: () {},
                                        icon: Text(
                                          "${item.progress}",
                                        ),
                                      );
                                    }
                                    else if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
                                      Fluttertoast.showToast(
                                        msg: "Failed or canceled download try again",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                      );
                                      return IconButton(
                                        onPressed: () async {
                                          await FlutterDownloader.loadTasksWithRawQuery(
                                            query: "delete from task where url = '${widget.fileUrl}';",
                                          );
                                          await file.delete().then((value) {
                                            print("yes deleted file");
                                          }).catchError((err) {
                                            print("no deleted file");
                                          });
                                          f.downloadFile(widget.fileUrl, "${widget.fileName}");
                                        },
                                        icon: Icon(Icons.download),
                                      );
                                    }
                                    else {
                                      Fluttertoast.showToast(
                                        msg: "The file there is not exist in download folder 2",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.black,
                                      );
                                      return IconButton(
                                        onPressed: () async {
                                          await FlutterDownloader.loadTasksWithRawQuery(
                                            query: "delete from task where url = '${widget.fileUrl}';",
                                          );
                                          f.downloadFile(widget.fileUrl, "${widget.fileName}");
                                        },
                                        icon: Icon(Icons.download),
                                      );
                                    }
                                  }
                                }
                                else if (snapshot.hasError) {
                                  return Text("خطا");
                                } else {
                                  return Text("...");
                                }
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          else if(snapshot.hasError){
            return Text("خطا");
          }else{
            return Text("انتظر ...");
          }
        }
      ),
    );
  }

}

class PageNumberController extends GetxController {}

/*
IconButton(
                        onPressed: () async {},
                        icon: Icon(Icons.download),
                      )
 */
