import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const DDalKKackApp());
}

class DDalKKackApp extends StatelessWidget {
  const DDalKKackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DDalKKack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3366FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}

enum ExpenseStatus {
  pending('검토중'),
  approved('승인'),
  rejected('반려');

  final String label;
  const ExpenseStatus(this.label);
}

class ReceiptSummary {
  final String id;
  final String merchant;
  final int amount;
  final String category;
  final ExpenseStatus status;
  final String date;
  final String time;
  final String cardType;
  final String purpose;
  final String participants;
  final String? imagePath;
  final List<String> warnings;
  final List<String> rejectionReasons;

  ReceiptSummary({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.status,
    this.date = '',
    this.time = '',
    this.cardType = '',
    this.purpose = '',
    this.participants = '',
    this.imagePath,
    this.warnings = const [],
    this.rejectionReasons = const [],
  });
}

class QuickReceipt {
  final String id;
  final String imagePath;
  final String fileName;
  final DateTime createdAt;
  bool selected;

  QuickReceipt({
    required this.id,
    required this.imagePath,
    required this.fileName,
    required this.createdAt,
    this.selected = false,
  });
}

class TripSummary {
  final int id;
  final String tripName;
  final String tripPurpose;
  final String tripCompanions;
  final String startDate;
  final String endDate;

  TripSummary({
    required this.id,
    required this.tripName,
    required this.tripPurpose,
    required this.tripCompanions,
    required this.startDate,
    required this.endDate,
  });
}

class RegisteredCard {
  final int id;
  final String cardType;
  final String cardCompany;
  final String cardNumber;
  final bool isActive;

  RegisteredCard({
    required this.id,
    required this.cardType,
    required this.cardCompany,
    required this.cardNumber,
    this.isActive = true,
  });
}

class AnalyzeReceiptResult {
  final String merchant;
  final int amount;
  final String date;
  final String time;
  final String category;
  final String cardType;
  final String purpose;
  final String participants;
  final ExpenseStatus status;
  final List<String> warnings;
  final List<String> rejectionReasons;
  final String? imagePath;

  AnalyzeReceiptResult({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.time,
    required this.category,
    required this.cardType,
    required this.status,
    required this.warnings,
    required this.rejectionReasons,
    this.purpose = '',
    this.participants = '',
    this.imagePath,
  });

  ReceiptSummary toReceiptSummary() {
    return ReceiptSummary(
      id: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      merchant: merchant,
      amount: amount,
      category: category,
      status: status,
      date: date,
      time: time,
      cardType: cardType,
      purpose: purpose,
      participants: participants,
      imagePath: imagePath,
      warnings: warnings,
      rejectionReasons: rejectionReasons,
    );
  }

  AnalyzeReceiptResult copyWith({
    String? merchant,
    int? amount,
    String? date,
    String? time,
    String? category,
    String? cardType,
    String? purpose,
    String? participants,
    ExpenseStatus? status,
    List<String>? warnings,
    List<String>? rejectionReasons,
    String? imagePath,
  }) {
    return AnalyzeReceiptResult(
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      cardType: cardType ?? this.cardType,
      purpose: purpose ?? this.purpose,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      warnings: warnings ?? this.warnings,
      rejectionReasons: rejectionReasons ?? this.rejectionReasons,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class PolicyValidationResult {
  final ExpenseStatus status;
  final List<String> warnings;
  final List<String> rejectionReasons;

  PolicyValidationResult({
    required this.status,
    required this.warnings,
    required this.rejectionReasons,
  });
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool isLoggedIn = false;

  final List<QuickReceipt> quickReceipts = [];
  final List<ReceiptSummary> receipts = [
    ReceiptSummary(
      id: 'sample_1',
      merchant: '스타벅스 광운대점',
      amount: 15000,
      category: '회의비',
      status: ExpenseStatus.pending,
      date: '2026.05.01',
      time: '14:30',
      cardType: '회사카드',
      warnings: ['회의비 목적 입력 필요', '참여자 정보 누락'],
    ),
    ReceiptSummary(
      id: 'sample_2',
      merchant: 'KTX',
      amount: 59800,
      category: '교통비',
      status: ExpenseStatus.approved,
      date: '2026.05.02',
      time: '09:10',
      cardType: '회사카드',
    ),
  ];

  final List<TripSummary> trips = [
    TripSummary(
      id: 1,
      tripName: '부산 고객사 방문',
      tripPurpose: '계약 협의 및 현장 점검',
      tripCompanions: '백다인, 원의재',
      startDate: '2026.05.10',
      endDate: '2026.05.12',
    ),
  ];

  final List<RegisteredCard> cards = [
    RegisteredCard(
      id: 1,
      cardType: '회사카드',
      cardCompany: '신한',
      cardNumber: '5234 ****',
    ),
    RegisteredCard(
      id: 2,
      cardType: '정부지원카드',
      cardCompany: 'BC',
      cardNumber: '9876 ****',
    ),
  ];

  void addReceipt(ReceiptSummary receipt) {
    setState(() {
      receipts.insert(0, receipt);
    });
  }

  void addQuickReceipt(QuickReceipt receipt) {
    setState(() {
      quickReceipts.insert(0, receipt);
    });
  }

  void addQuickReceipts(List<QuickReceipt> items) {
    setState(() {
      quickReceipts.insertAll(0, items);
    });
  }

  void removeSelectedQuickReceipts() {
    setState(() {
      quickReceipts.removeWhere((receipt) => receipt.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return LoginScreen(
        onLogin: () {
          setState(() {
            isLoggedIn = true;
          });
        },
      );
    }

    return MainShell(
      receipts: receipts,
      quickReceipts: quickReceipts,
      trips: trips,
      cards: cards,
      onAddReceipt: addReceipt,
      onAddQuickReceipt: addQuickReceipt,
      onAddQuickReceipts: addQuickReceipts,
      onRemoveSelectedQuickReceipts: removeSelectedQuickReceipts,
      onLogout: () {
        setState(() {
          isLoggedIn = false;
        });
      },
      refresh: () => setState(() {}),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DDalKKack',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3366FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '관리자가 등록한 계정으로 로그인하세요.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: '이메일 또는 전화번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          if (idController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            setState(() {
                              error = '아이디와 비밀번호를 입력하세요.';
                            });
                            return;
                          }
                          widget.onLogin();
                        },
                        child: const Text('로그인'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '회원가입은 제공하지 않습니다.\n사용자 계정은 관리자 웹에서 사전 등록됩니다.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final List<ReceiptSummary> receipts;
  final List<QuickReceipt> quickReceipts;
  final List<TripSummary> trips;
  final List<RegisteredCard> cards;
  final ValueChanged<ReceiptSummary> onAddReceipt;
  final ValueChanged<QuickReceipt> onAddQuickReceipt;
  final ValueChanged<List<QuickReceipt>> onAddQuickReceipts;
  final VoidCallback onRemoveSelectedQuickReceipts;
  final VoidCallback onLogout;
  final VoidCallback refresh;

  const MainShell({
    super.key,
    required this.receipts,
    required this.quickReceipts,
    required this.trips,
    required this.cards,
    required this.onAddReceipt,
    required this.onAddQuickReceipt,
    required this.onAddQuickReceipts,
    required this.onRemoveSelectedQuickReceipts,
    required this.onLogout,
    required this.refresh,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        receipts: widget.receipts,
        quickReceiptCount: widget.quickReceipts.length,
        onReceiptRegister: () async {
          final result = await Navigator.push<ReceiptSummary>(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptRegisterScreen(),
            ),
          );

          if (result != null) {
            widget.onAddReceipt(result);
            setState(() {
              index = 1;
            });
          }
        },
        onQuickRegister: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuickRegisterScreen(
                quickReceipts: widget.quickReceipts,
                onAddQuickReceipt: widget.onAddQuickReceipt,
                onAddQuickReceipts: widget.onAddQuickReceipts,
                onRemoveSelected: widget.onRemoveSelectedQuickReceipts,
                onAddReceipt: widget.onAddReceipt,
                refresh: widget.refresh,
              ),
            ),
          );
        },
      ),
      HistoryScreen(receipts: widget.receipts),
      TripsScreen(trips: widget.trips),
      StatsScreen(receipts: widget.receipts),
      MenuScreen(
        cards: widget.cards,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: '내역'),
          NavigationDestination(icon: Icon(Icons.luggage), label: '출장'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: '통계'),
          NavigationDestination(icon: Icon(Icons.menu), label: '전체 메뉴'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<ReceiptSummary> receipts;
  final int quickReceiptCount;
  final VoidCallback onReceiptRegister;
  final VoidCallback onQuickRegister;

  const HomeScreen({
    super.key,
    required this.receipts,
    required this.quickReceiptCount,
    required this.onReceiptRegister,
    required this.onQuickRegister,
  });

  @override
  Widget build(BuildContext context) {
    final total = receipts.fold<int>(0, (sum, item) => sum + item.amount);
    final approved = receipts.where((e) => e.status == ExpenseStatus.approved).length;
    final pending = receipts.where((e) => e.status == ExpenseStatus.pending).length;
    final rejected = receipts.where((e) => e.status == ExpenseStatus.rejected).length;

    return AppPage(
      title: '이번 달 대시보드',
      subtitle: '지출 현황과 처리 상태를 한 번에 확인합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardCard(
            total: total,
            approved: approved,
            pending: pending,
            rejected: rejected,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.receipt_long,
                  title: '영수증 등록',
                  description: '촬영/업로드 후 즉시 AI 분석',
                  onTap: onReceiptRegister,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionCard(
                  icon: Icons.flash_on,
                  title: '빠른 등록',
                  description: '분석 없이 저장 후 일괄 분석',
                  onTap: onQuickRegister,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InfoCard(
            icon: Icons.move_to_inbox,
            title: '빠른등록 보관함',
            description: '현재 분석 대기 영수증 $quickReceiptCount장',
          ),
          const SizedBox(height: 24),
          const Text(
            '최근 내역',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (receipts.isEmpty)
            const EmptyCard(
              icon: Icons.receipt_long,
              title: '아직 등록된 내역이 없습니다.',
              description: '영수증을 등록하면 최근 내역이 표시됩니다.',
            )
          else
            ...receipts.take(3).map(
                  (receipt) => ReceiptTile(
                receipt: receipt,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptDetailScreen(receipt: receipt),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ReceiptRegisterScreen extends StatelessWidget {
  ReceiptRegisterScreen({super.key});

  final ImagePicker picker = ImagePicker();

  Future<void> _handleImage(BuildContext context, ImageSource source) async {
    final file = await picker.pickImage(source: source);
    if (file == null || !context.mounted) return;

    final savedPath = await savePickedFile(file);
    final initialResult = createDummyAnalysisResult(savedPath);

    if (!context.mounted) return;

    final receipt = await Navigator.push<ReceiptSummary>(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(initialResult: initialResult),
      ),
    );

    if (!context.mounted) return;

    if (receipt != null) {
      Navigator.pop(context, receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '영수증 등록',
      subtitle: '영수증을 촬영하거나 업로드하면 즉시 AI 분석을 진행합니다.',
      showBack: true,
      child: Column(
        children: [
          BigButton(
            icon: Icons.camera_alt,
            title: '촬영하기',
            onTap: () => _handleImage(context, ImageSource.camera),
          ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.photo,
            title: '갤러리에서 업로드',
            onTap: () => _handleImage(context, ImageSource.gallery),
          ),
          const SizedBox(height: 18),
          const InfoCard(
            icon: Icons.info_outline,
            title: '빠른등록과의 차이',
            description:
            '영수증 등록은 이미지 선택 직후 AI 분석으로 이동합니다. 빠른등록은 분석 없이 보관함에 저장한 뒤 나중에 일괄 분석합니다.',
          ),
        ],
      ),
    );
  }
}

class QuickRegisterScreen extends StatefulWidget {
  final List<QuickReceipt> quickReceipts;
  final ValueChanged<QuickReceipt> onAddQuickReceipt;
  final ValueChanged<List<QuickReceipt>> onAddQuickReceipts;
  final VoidCallback onRemoveSelected;
  final ValueChanged<ReceiptSummary> onAddReceipt;
  final VoidCallback refresh;

  const QuickRegisterScreen({
    super.key,
    required this.quickReceipts,
    required this.onAddQuickReceipt,
    required this.onAddQuickReceipts,
    required this.onRemoveSelected,
    required this.onAddReceipt,
    required this.refresh,
  });

  @override
  State<QuickRegisterScreen> createState() => _QuickRegisterScreenState();
}

class _QuickRegisterScreenState extends State<QuickRegisterScreen> {
  final picker = ImagePicker();

  Future<void> pickOne(ImageSource source) async {
    final file = await picker.pickImage(source: source);
    if (file == null) return;

    final savedPath = await savePickedFile(file);
    final receipt = QuickReceipt(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: savedPath,
      fileName: savedPath.split(Platform.pathSeparator).last,
      createdAt: DateTime.now(),
    );

    widget.onAddQuickReceipt(receipt);
    setState(() {});
  }

  Future<void> pickMultiple() async {
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    final items = <QuickReceipt>[];

    for (final file in files) {
      final savedPath = await savePickedFile(file);
      items.add(
        QuickReceipt(
          id: 'quick_${DateTime.now().millisecondsSinceEpoch}_${items.length}',
          imagePath: savedPath,
          fileName: savedPath.split(Platform.pathSeparator).last,
          createdAt: DateTime.now(),
        ),
      );
    }

    widget.onAddQuickReceipts(items);
    setState(() {});
  }

  Future<void> analyzeSelected() async {
    final selected = widget.quickReceipts.where((e) => e.selected).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 영수증을 선택하세요.')),
      );
      return;
    }

    final generated = selected
        .map((quick) => createDummyAnalysisResult(quick.imagePath).toReceiptSummary())
        .toList();

    final shouldSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BatchAnalysisScreen(results: generated),
      ),
    );

    if (shouldSave == true) {
      for (final receipt in generated) {
        widget.onAddReceipt(receipt);
      }
      widget.onRemoveSelected();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.quickReceipts.where((e) => e.selected).length;

    return AppPage(
      title: '빠른 등록 보관함',
      subtitle: '영수증을 분석 없이 저장하고, 나중에 여러 장을 한 번에 분석합니다.',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BigButton(
                  icon: Icons.camera_alt,
                  title: '촬영하기',
                  onTap: () => pickOne(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigButton(
                  icon: Icons.photo_library,
                  title: '갤러리',
                  onTap: pickMultiple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '선택됨: $selectedCount장 / 전체 ${widget.quickReceipts.length}장',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: selectedCount == 0
                              ? null
                              : () {
                            widget.onRemoveSelected();
                            setState(() {});
                          },
                          child: const Text('선택 삭제'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: selectedCount == 0 ? null : analyzeSelected,
                          child: const Text('일괄 분석'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '저장된 영수증',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.quickReceipts.isEmpty)
            const EmptyCard(
              icon: Icons.move_to_inbox,
              title: '보관함이 비어 있습니다.',
              description: '촬영하거나 갤러리에서 영수증 이미지를 추가해보세요.',
            )
          else
            ...widget.quickReceipts.map(
                  (receipt) => Card(
                child: CheckboxListTile(
                  value: receipt.selected,
                  onChanged: (value) {
                    setState(() {
                      receipt.selected = value ?? false;
                    });
                  },
                  title: Text(receipt.fileName),
                  subtitle: Text(receipt.imagePath),
                  secondary: const Icon(Icons.receipt_long),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnalysisResultScreen extends StatefulWidget {
  final AnalyzeReceiptResult initialResult;

  const AnalysisResultScreen({
    super.key,
    required this.initialResult,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  late TextEditingController merchantController;
  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController categoryController;
  late TextEditingController cardTypeController;
  late TextEditingController purposeController;
  late TextEditingController participantsController;

  @override
  void initState() {
    super.initState();
    final r = widget.initialResult;
    merchantController = TextEditingController(text: r.merchant);
    amountController = TextEditingController(text: r.amount.toString());
    dateController = TextEditingController(text: r.date);
    timeController = TextEditingController(text: r.time);
    categoryController = TextEditingController(text: r.category);
    cardTypeController = TextEditingController(text: r.cardType);
    purposeController = TextEditingController(text: r.purpose);
    participantsController = TextEditingController(text: r.participants);
  }

  @override
  void dispose() {
    merchantController.dispose();
    amountController.dispose();
    dateController.dispose();
    timeController.dispose();
    categoryController.dispose();
    cardTypeController.dispose();
    purposeController.dispose();
    participantsController.dispose();
    super.dispose();
  }

  AnalyzeReceiptResult buildResult() {
    final policy = validateReceiptPolicy(
      category: categoryController.text,
      amount: int.tryParse(amountController.text) ?? 0,
      cardType: cardTypeController.text,
      purpose: purposeController.text,
      participants: participantsController.text,
      time: timeController.text,
    );

    return widget.initialResult.copyWith(
      merchant: merchantController.text,
      amount: int.tryParse(amountController.text) ?? 0,
      date: dateController.text,
      time: timeController.text,
      category: categoryController.text,
      cardType: cardTypeController.text,
      purpose: purposeController.text,
      participants: participantsController.text,
      status: policy.status,
      warnings: policy.warnings,
      rejectionReasons: policy.rejectionReasons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = buildResult();

    return AppPage(
      title: 'AI 분석 결과',
      subtitle: 'AI가 추출한 정보를 확인하고 필요한 경우 수정하세요.',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: '가맹점', controller: merchantController, onChanged: (_) => setState(() {})),
          AppTextField(label: '금액', controller: amountController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
          AppTextField(label: '날짜', controller: dateController, onChanged: (_) => setState(() {})),
          AppTextField(label: '시간', controller: timeController, onChanged: (_) => setState(() {})),
          AppTextField(label: '카테고리', controller: categoryController, onChanged: (_) => setState(() {})),
          AppTextField(label: '카드 종류', controller: cardTypeController, onChanged: (_) => setState(() {})),
          AppTextField(label: '사용 목적', controller: purposeController, onChanged: (_) => setState(() {})),
          AppTextField(label: '참여자', controller: participantsController, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          StatusBox(status: result.status),
          const SizedBox(height: 12),
          WarningBox(warnings: result.warnings),
          const SizedBox(height: 12),
          RejectionBox(reasons: result.rejectionReasons),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, result.toReceiptSummary());
              },
              child: const Text('제출하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class BatchAnalysisScreen extends StatelessWidget {
  final List<ReceiptSummary> results;

  const BatchAnalysisScreen({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'AI 일괄 분석',
      subtitle: '선택된 영수증 이미지를 AI 분석 모듈로 전달하는 더미 화면입니다.',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            icon: Icons.smart_toy,
            title: '분석 대상',
            description: '${results.length}장의 영수증 이미지',
          ),
          const SizedBox(height: 16),
          const Text(
            '더미 분석 결과',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...results.map((receipt) => ReceiptTile(receipt: receipt)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('내역에 저장'),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<ReceiptSummary> receipts;

  const HistoryScreen({
    super.key,
    required this.receipts,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '정산 내역',
      subtitle: '분석 및 제출된 지출 내역을 확인합니다.',
      child: receipts.isEmpty
          ? const EmptyCard(
        icon: Icons.receipt_long,
        title: '내역이 없습니다.',
        description: '영수증을 등록하면 이곳에 표시됩니다.',
      )
          : Column(
        children: receipts
            .map(
              (receipt) => ReceiptTile(
            receipt: receipt,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceiptDetailScreen(receipt: receipt),
                ),
              );
            },
          ),
        )
            .toList(),
      ),
    );
  }
}

class ReceiptDetailScreen extends StatelessWidget {
  final ReceiptSummary receipt;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '지출 상세보기',
      subtitle: '영수증 이미지, 분석 결과, 규정 검증 결과를 확인합니다.',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReceiptTile(receipt: receipt),
          const SizedBox(height: 12),
          DetailCard(
            title: '분석 결과',
            items: {
              '가맹점': receipt.merchant,
              '금액': formatWon(receipt.amount),
              '날짜': receipt.date,
              '시간': receipt.time,
              '카테고리': receipt.category,
              '카드 종류': receipt.cardType,
              '사용 목적': receipt.purpose.isEmpty ? '미입력' : receipt.purpose,
              '참여자': receipt.participants.isEmpty ? '미입력' : receipt.participants,
            },
          ),
          const SizedBox(height: 12),
          WarningBox(warnings: receipt.warnings),
          const SizedBox(height: 12),
          RejectionBox(reasons: receipt.rejectionReasons),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.image,
            title: '영수증 이미지 경로',
            description: receipt.imagePath ?? '이미지 없음',
          ),
        ],
      ),
    );
  }
}

class TripsScreen extends StatelessWidget {
  final List<TripSummary> trips;

  const TripsScreen({
    super.key,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '출장',
      subtitle: '출장 정보와 관련 지출을 연결하기 위한 화면입니다.',
      child: trips.isEmpty
          ? const EmptyCard(
        icon: Icons.luggage,
        title: '등록된 출장이 없습니다.',
        description: '출장 등록 기능은 다음 단계에서 연결합니다.',
      )
          : Column(
        children: trips
            .map(
              (trip) => Card(
            child: ListTile(
              leading: const Icon(Icons.luggage),
              title: Text(trip.tripName),
              subtitle: Text(
                '${trip.startDate} ~ ${trip.endDate}\n${trip.tripPurpose}\n동행인: ${trip.tripCompanions}',
              ),
              isThreeLine: true,
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  final List<ReceiptSummary> receipts;

  const StatsScreen({
    super.key,
    required this.receipts,
  });

  @override
  Widget build(BuildContext context) {
    final total = receipts.fold<int>(0, (sum, item) => sum + item.amount);
    final approved = receipts.where((e) => e.status == ExpenseStatus.approved).length;
    final pending = receipts.where((e) => e.status == ExpenseStatus.pending).length;
    final rejected = receipts.where((e) => e.status == ExpenseStatus.rejected).length;

    return AppPage(
      title: '통계',
      subtitle: '이번 달 지출 흐름을 요약합니다.',
      child: Column(
        children: [
          DashboardCard(
            total: total,
            approved: approved,
            pending: pending,
            rejected: rejected,
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.pie_chart,
            title: '카테고리별 지출',
            description: '식비/회의비, 교통비, 기타 항목별 통계는 DB 연결 후 확장합니다.',
          ),
        ],
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final List<RegisteredCard> cards;
  final VoidCallback onLogout;

  const MenuScreen({
    super.key,
    required this.cards,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '전체 메뉴',
      subtitle: '내 정보, 카드, 규정, 로그아웃 기능을 확인합니다.',
      child: Column(
        children: [
          MenuTile(
            icon: Icons.person,
            title: '내 정보 관리',
            subtitle: '사용자 정보 확인',
            onTap: () {},
          ),
          MenuTile(
            icon: Icons.credit_card,
            title: '카드 관리',
            subtitle: '등록된 카드 정보 확인',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CardInfoScreen(cards: cards),
                ),
              );
            },
          ),
          MenuTile(
            icon: Icons.rule,
            title: '규정 확인',
            subtitle: '회사 경비 규정 확인',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RulesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onLogout,
              child: const Text('로그아웃'),
            ),
          ),
        ],
      ),
    );
  }
}

class CardInfoScreen extends StatelessWidget {
  final List<RegisteredCard> cards;

  const CardInfoScreen({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '카드 관리',
      subtitle: '등록된 카드 정보를 확인합니다.',
      showBack: true,
      child: Column(
        children: cards
            .map(
              (card) => Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(card.cardType),
              subtitle: Text('${card.cardCompany} · ${card.cardNumber}'),
              trailing: Text(card.isActive ? '사용 가능' : '중지'),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '규정 확인',
      subtitle: '경비 처리 전 확인해야 할 주요 규정입니다.',
      showBack: true,
      child: const Column(
        children: [
          InfoCard(
            icon: Icons.restaurant,
            title: '회사카드 식대',
            description: '일반 식대는 1인 1식 기준 최대 15,000원까지 인정됩니다. 야근 식대는 오후 8시 이후 1인 기준 최대 20,000원까지 인정됩니다.',
          ),
          InfoCard(
            icon: Icons.groups,
            title: '회의비/접대비',
            description: '회의비와 접대비는 사용 목적 및 참여자 정보 입력이 필요합니다.',
          ),
          InfoCard(
            icon: Icons.credit_card,
            title: '정부지원카드',
            description: '승인된 과제 목적에 한하여 사용 가능하며, 주류·유흥업소·개인 용도 사용은 제한됩니다.',
          ),
          InfoCard(
            icon: Icons.luggage,
            title: '출장비',
            description: '출장 관련 지출은 출장 ID 또는 관련 업무와 연결해야 합니다.',
          ),
        ],
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DDalKKack',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final int total;
  final int approved;
  final int pending;
  final int rejected;

  const DashboardCard({
    super.key,
    required this.total,
    required this.approved,
    required this.pending,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이번 달 지출 합계', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              formatWon(total),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: StatusChip(label: '승인 $approved', status: ExpenseStatus.approved)),
                const SizedBox(width: 8),
                Expanded(child: StatusChip(label: '검토중 $pending', status: ExpenseStatus.pending)),
                const SizedBox(width: 8),
                Expanded(child: StatusChip(label: '반려 $rejected', status: ExpenseStatus.rejected)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final ExpenseStatus status;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 145,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BigButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const BigButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 42, color: Colors.grey),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptTile extends StatelessWidget {
  final ReceiptSummary receipt;
  final VoidCallback? onTap;

  const ReceiptTile({
    super.key,
    required this.receipt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(receipt.status);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.receipt_long),
        title: Text(receipt.merchant),
        subtitle: Text('${receipt.category} · ${receipt.cardType}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatWon(receipt.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(receipt.status.label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final Map<String, String> items;

  const DetailCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(entry.key, style: const TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
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

class WarningBox extends StatelessWidget {
  final List<String> warnings;

  const WarningBox({
    super.key,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return const InfoCard(
        icon: Icons.check_circle,
        title: '규정 검증 결과',
        description: '현재 감지된 경고가 없습니다.',
      );
    }

    return Card(
      color: const Color(0xFFFFF7ED),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('규정 검증 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...warnings.map((e) => Text('• $e')),
          ],
        ),
      ),
    );
  }
}

class RejectionBox extends StatelessWidget {
  final List<String> reasons;

  const RejectionBox({
    super.key,
    required this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('반려 사유', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            ...reasons.map(
                  (e) => Text('• $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final ExpenseStatus status;

  const StatusBox({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.verified,
      title: '처리 상태',
      description: status.label,
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

PolicyValidationResult validateReceiptPolicy({
  required String category,
  required int amount,
  required String cardType,
  required String purpose,
  required String participants,
  required String time,
}) {
  final warnings = <String>[];
  final rejections = <String>[];

  if (cardType.contains('회사') && category.contains('식') && amount > 15000) {
    warnings.add('회사카드 일반 식대는 1인 1식 기준 15,000원을 초과할 수 있습니다.');
  }

  if ((category.contains('회의') || category.contains('접대')) && purpose.trim().isEmpty) {
    warnings.add('회의비/접대비로 처리하려면 사용 목적 입력이 필요합니다.');
  }

  if ((category.contains('회의') || category.contains('접대')) && participants.trim().isEmpty) {
    warnings.add('회의비/접대비로 처리하려면 참여자 정보 입력이 필요합니다.');
  }

  if (cardType.contains('정부') && purpose.trim().isEmpty) {
    warnings.add('정부지원카드는 과제 관련 사용 목적을 반드시 입력해야 합니다.');
  }

  if (cardType.contains('정부') && (category.contains('접대') || category.contains('회식'))) {
    rejections.add('정부지원카드는 접대비 또는 회식비로 사용할 수 없습니다.');
  }

  if (category.contains('주류') || category.contains('담배') || category.contains('유흥')) {
    rejections.add('주류, 담배, 유흥업소 관련 지출은 비용 처리할 수 없습니다.');
  }

  final status = rejections.isNotEmpty
      ? ExpenseStatus.rejected
      : warnings.isNotEmpty
      ? ExpenseStatus.pending
      : ExpenseStatus.approved;

  return PolicyValidationResult(
    status: status,
    warnings: warnings,
    rejectionReasons: rejections,
  );
}

AnalyzeReceiptResult createDummyAnalysisResult(String imagePath) {
  final policy = validateReceiptPolicy(
    category: '회의비',
    amount: 15000,
    cardType: '회사카드',
    purpose: '',
    participants: '',
    time: '14:30',
  );

  return AnalyzeReceiptResult(
    merchant: '스타벅스 광운대점',
    amount: 15000,
    date: '2026.05.01',
    time: '14:30',
    category: '회의비',
    cardType: '회사카드',
    purpose: '',
    participants: '',
    status: policy.status,
    warnings: policy.warnings,
    rejectionReasons: policy.rejectionReasons,
    imagePath: imagePath,
  );
}

Future<String> savePickedFile(XFile file) async {
  final directory = await getApplicationDocumentsDirectory();
  final receiptDir = Directory('${directory.path}${Platform.pathSeparator}receipts');

  if (!await receiptDir.exists()) {
    await receiptDir.create(recursive: true);
  }

  final extension = file.path.split('.').last;
  final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.$extension';
  final savedFile = File('${receiptDir.path}${Platform.pathSeparator}$fileName');

  await File(file.path).copy(savedFile.path);

  return savedFile.path;
}

String formatWon(int amount) {
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원';
}

Color statusColor(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.approved:
      return const Color(0xFF0F9D58);
    case ExpenseStatus.pending:
      return const Color(0xFF2563EB);
    case ExpenseStatus.rejected:
      return const Color(0xFFD93025);
  }
}