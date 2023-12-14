import 'dart:convert';
import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';
import 'package:motafawk/launch_link.dart';
import 'package:motafawk/my_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:printing/printing.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import '../../controller/download_files_controller.dart';
import '../../tmp/my_sfpdf.dart';
import '../../vars.dart' as v;
import '../../funs.dart' as f;
import 'package:flutter_animate/flutter_animate.dart';

class PdfReader extends StatefulWidget {
  final String fileUri;
  final String fileName;
  final String? indexes;
  const PdfReader({super.key, required this.fileUri, required this.fileName, required this.indexes});

  @override
  State<PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends State<PdfReader> {
  PageNumberController pageNumberController = Get.put(PageNumberController());
  DownloadFilesController downloadFilesController = Get.put(DownloadFilesController());

  PdfViewerController pdfViewerController = PdfViewerController();
  TextEditingController _txtpagenumber = TextEditingController();

  bool isFirstPage = true;
  bool isLastPage = false;

  String fileUrlHex = "";

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
            int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
            if(watchFullRewardedAd == 1) return;

            await Clipboard.setData(ClipboardData(text: details.selectedText??""));
            pdfViewerController.clearSelection();
          },
          child: Text('Copy', style: TextStyle(fontSize: 17)),
        ),
      ),
    );
    _overlayState!.insert(_overlayEntry!);
  }

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  void initState() {
    super.initState();

    adsManagerController.pdfReaderConfettiController = ConfettiController(duration: Duration(milliseconds: 4500));

    if(widget.fileUri.contains("http")){
      fileUrlHex = f.convertArabicToHex("${widget.fileUri}");
    } else {
      fileUrlHex = f.convertArabicToHex("${v.filesLink}/${widget.fileUri}");
    }
  }
  @override
  void dispose() {
    adsManagerController.pdfReaderConfettiController.dispose();
    pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              elevation: 15,
              titleSpacing: -8,
              title: Container(
                width: w,
                child: GestureDetector(
                  onTap: () async {
                    Get.snackbar(
                      "اسم الملف: ", "",
                      mainButton: TextButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Icon(Icons.close),
                      ),
                      backgroundColor: v.tertiarycolor[100],
                      duration: Duration(seconds: 5),
                      messageText: Text(
                        "${widget.fileName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.6
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "${widget.fileName}",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, size: 24, color: Colors.black,),
                            SizedBox(width: 8),
                            Text(
                              "فتح الملف في تطبيق اخر",
                              style: TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if(widget.indexes != null)
                        PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.menu, size: 24, color: Colors.black,),
                            SizedBox(width: 8),
                            Text(
                              "الفهرس",
                              style: TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (int i) async {
                    if(i == 0) {
                      File? file = await DefaultCacheManager().getSingleFile("${fileUrlHex}");
                      await OpenFile.open("${file.path}");
                    } else if(i == 1) {
                      // print("${widget.indexes}");
                      List indexes = jsonDecode(widget.indexes??"[]");
                      for (Map element in indexes) {
                        print(element);
                      }
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => IndexDialog(indexes: indexes, pdfViewerController: pdfViewerController),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          body: FutureBuilder(
              future: DefaultCacheManager().getSingleFile("${fileUrlHex}"),
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
                          initialZoomLevel: 1.001,
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
                            launchLink(url: pdfHyperlinkClickedDetails.uri);
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
                        color: v.secondarycolor.withOpacity(0.7),
                        child: Container(
                          width: w,
                          height: 45,
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
                                  int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                  if(watchFullRewardedAd == 1) return;

                                  await Printing.layoutPdf(
                                      name: "${widget.fileName}",
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
                                      query: "select * from task where url = '${fileUrlHex}' order by time_created desc;",
                                    ),
                                    builder: (context, AsyncSnapshot<List<DownloadTask>?> snapshot) {
                                      if (snapshot.hasData) {
                                        File file = File("${v.downloadPath}/${widget.fileName}.pdf");
                                        if (snapshot.data!.length == 0) {
                                          print("file path: ${v.downloadPath}/${widget.fileName}.pdf");
                                          return IconButton(
                                            onPressed: () async {
                                              int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                              if(watchFullRewardedAd == 1) return;

                                              if (file.existsSync()) {
                                                Get.defaultDialog(
                                                  titlePadding: EdgeInsets.zero,
                                                  title: "",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                                  content: Column(
                                                    children: [
                                                      Text("الملف ${widget.fileName} موجود بالفعل، هل تريد التنزيل على اية حال؟"),
                                                      SizedBox(height: 16),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () async {
                                                              file.deleteSync();
                                                              f.downloadFile(widget.fileUri, "${widget.fileName}");
                                                              Get.back();
                                                            },
                                                            child: Text("نعم"),
                                                          ),
                                                          TextButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                              foregroundColor: Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              Get.back();
                                                            },
                                                            child: Text("لا"),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              else {
                                                f.downloadFile(widget.fileUri, "${widget.fileName}");
                                              }
                                            },
                                            icon: Icon(Icons.arrow_downward_sharp),
                                          );
                                        }
                                        else {
                                          final DownloadTask item = snapshot.data![0];
                                          DownloadTaskStatus status = item.status;

                                          print("file download status: ${status}");

                                          if (status == DownloadTaskStatus.complete && file.existsSync()) {
                                            return Container(
                                              width: 40,
                                              child: PopupMenuButton(
                                                iconSize: 24,
                                                itemBuilder: (context) {
                                                  return [
                                                    PopupMenuItem(
                                                      value: 0,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.open_in_new, size: 24,),
                                                          SizedBox(width: 8),
                                                          Text("فتح", style: TextStyle(fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.share, size: 24,),
                                                          SizedBox(width: 8),
                                                          Text("مشاركة", style: TextStyle(fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 2,
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete_outline, size: 24, color: Colors.pink[800],),
                                                          SizedBox(width: 8),
                                                          Text("حذف", style: TextStyle(fontSize: 14, color: Colors.pink[800],),),
                                                        ],
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                onSelected: (int val) async {
                                                  int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                                  if(watchFullRewardedAd == 1) return;

                                                  if(val == 0) {
                                                    if (status == DownloadTaskStatus.complete && !file.existsSync()) {
                                                      print("The file there is not exist in download folder!: ${item}");
                                                      // await Fluttertoast.showToast(
                                                      //   msg: "The file there is not exist in download folder!",
                                                      //   backgroundColor: Colors.amber,
                                                      //   textColor: Colors.black,
                                                      // );
                                                      await FlutterDownloader.loadTasksWithRawQuery(
                                                        query: "delete from task where url = '${fileUrlHex}';",
                                                      );
                                                      print("deleted the '${widget.fileUri}' from db");
                                                      // controller.update();
                                                      f.downloadFile(widget.fileUri, "${widget.fileName}");
                                                    } else {
                                                      await FlutterDownloader.open(taskId: item.taskId);
                                                    }
                                                  }
                                                  else if(val == 1) {
                                                    if(f.checkExistFile(item) == false){return;}
                                                    await Share.shareFiles(["${item.savedDir}/${item.filename}"]);
                                                  }
                                                  else if(val == 2) {
                                                    print("delete file");
                                                    if(File("${item.savedDir}/${item.filename}").existsSync()){
                                                      File("${item.savedDir}/${item.filename}").deleteSync();
                                                    }
                                                    FlutterDownloader.remove(
                                                      taskId: item.taskId,
                                                      shouldDeleteContent: true,
                                                    ).then((value) {
                                                      Fluttertoast.showToast(
                                                          msg: "تم حذف: ${item.filename}",
                                                          backgroundColor: Colors.amber,
                                                          textColor: Colors.black,
                                                          gravity: ToastGravity.CENTER
                                                      );
                                                      controller.update();
                                                    });
                                                  }
                                                },
                                              ),
                                            );
                                          }
                                          else if (status == DownloadTaskStatus.running || status == DownloadTaskStatus.enqueued) {
                                            return InkWell(
                                              onTap: () async {
                                                if(file.existsSync()){
                                                  file.deleteSync();
                                                }
                                                await Future.delayed(Duration(milliseconds: 500));
                                                FlutterDownloader.remove(taskId: item.taskId).then((value) {
                                                  Fluttertoast.showToast(
                                                      msg: "تم الغاء: ${item.filename}",
                                                      backgroundColor: Colors.amber,
                                                      textColor: Colors.black,
                                                      gravity: ToastGravity.CENTER
                                                  );
                                                  controller.update();
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                child: CircularPercentIndicator(
                                                    radius: 20.0,
                                                    lineWidth: 5,
                                                    progressColor: v.primarycolor,
                                                    percent: (item.progress)/100,
                                                    center: Icon(Icons.close)
                                                ),
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
                                                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                                if(watchFullRewardedAd == 1) return;

                                                await FlutterDownloader.loadTasksWithRawQuery(
                                                  query: "delete from task where url = '${fileUrlHex}';",
                                                );
                                                await file.delete().then((value) {
                                                  print("yes deleted file");
                                                }).catchError((err) {
                                                  print("no deleted file");
                                                });
                                                f.downloadFile(widget.fileUri, "${widget.fileName}");
                                              },
                                              icon: Icon(Icons.arrow_downward_sharp),
                                            );
                                          }
                                          else {
                                            Fluttertoast.showToast(
                                              msg: "The file there is not exist in download folder 1",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.black,
                                            );
                                            return IconButton(
                                              onPressed: () async {
                                                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                                if(watchFullRewardedAd == 1) return;

                                                await FlutterDownloader.loadTasksWithRawQuery(
                                                  query: "delete from task where url = '${fileUrlHex}';",
                                                );
                                                f.downloadFile(widget.fileUri, "${widget.fileName}");
                                              },
                                              icon: Icon(Icons.arrow_downward_sharp),
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
                  return Center(child: ErrorInDb());
                }else{
                  return Center(child: LoadingData());
                }
              }
          ),
        ),

        ConfettiWidget(
          confettiController: adsManagerController.pdfReaderConfettiController,

          blastDirectionality: BlastDirectionality.explosive,

          emissionFrequency: 0.1,
          numberOfParticles: 60,

          minBlastForce: 10,
          maxBlastForce: 100,

          gravity: 0.1,

          createParticlePath: (size) {
            return f.drawStar(size);
          },
        ),

      ],
    );
  }

}

class IndexDialog extends StatelessWidget {
  final List indexes;
  final PdfViewerController pdfViewerController;
  IndexDialog({super.key, required this.indexes, required this.pdfViewerController});

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      iconPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Container(
        width: w,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                color: Colors.white,
                width: w * 0.85,
                // height: h * 0.6,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 55),
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: indexes.length,
                              itemBuilder: (context, int i) {
                                final item = indexes[i];
                                return Container(
                                  height: 50,
                                  child: TextButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(),
                                    ),
                                    onPressed: () async {
                                      int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "pdf_reader");
                                      if(watchFullRewardedAd == 1) return;
                                      pdfViewerController.jumpToPage(item['i']);
                                      Get.back();
                                    },
                                    child: Text("${item['name']}"),
                                  ),
                                );
                              },
                              separatorBuilder: (context, int i) {
                                return Divider(height: 1, color: v.primarycolor,);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Material(
                        color: Colors.white,
                        child: Container(
                          width: w * 0.85,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: v.primarycolor, width: 1.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.close, color: Colors.transparent,),
                              ),
                              Text(
                                'الفهرس',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




