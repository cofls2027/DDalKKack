package com.example.ddalkkack

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            DDalKKackApp()
        }
    }
}

/**
 * 분석 전 임시 저장 영수증.
 * 빠른등록 화면에서 관리한다.
 */
data class QuickReceipt(
    val id: String,
    val imagePath: String,
    val fileName: String,
    val createdAt: String,
    val selected: Boolean = false
)

/**
 * 분석/제출 이후 내역에 표시될 요약 데이터.
 * 지금은 mock 데이터이고, 나중에 Supabase receipts 테이블과 연결하면 된다.
 */
data class ReceiptSummary(
    val id: String,
    val merchant: String,
    val amount: Int,
    val category: String,
    val status: ExpenseStatus,
    val date: String = "",
    val time: String = "",
    val cardType: String = "",
    val cardCompany: String = "",
    val cardNumber: String = "",
    val purpose: String = "",
    val participants: String = "",
    val tripId: Long? = null,
    val imagePath: String? = null,
    val warnings: List<String> = emptyList(),
    val rejectionReasons: List<String> = emptyList()
)

data class AnalyzeReceiptRequest(
    val imagePaths: List<String>
)

data class AnalyzeReceiptResult(
    val merchant: String,
    val amount: Int,
    val date: String,
    val time: String,
    val category: String,
    val cardType: String,
    val cardCompany: String = "",
    val cardNumber: String = "",
    val purpose: String = "",
    val participants: String = "",
    val tripId: Long? = null,
    val status: ExpenseStatus,
    val warnings: List<String>,
    val rejectionReasons: List<String> = emptyList(),
    val imagePath: String?
)

data class PolicyValidationResult(
    val status: ExpenseStatus,
    val warnings: List<String>,
    val rejectionReasons: List<String>
)

enum class ExpenseStatus(
    val label: String,
    val color: Color,
    val background: Color
) {
    PendingAnalysis(
        label = "분석대기",
        color = Color(0xFF7C3AED),
        background = Color(0xFFF3E8FF)
    ),
    Reviewing(
        label = "검토중",
        color = Color(0xFF2563EB),
        background = Color(0xFFEFF4FF)
    ),
    Approved(
        label = "승인",
        color = Color(0xFF0F9D58),
        background = Color(0xFFE8F5E9)
    ),
    Rejected(
        label = "반려",
        color = Color(0xFFD93025),
        background = Color(0xFFFFEBEE)
    )
}

data class RegisteredCard(
    val id: Long,
    val cardType: String,
    val cardCompany: String,
    val cardNumber: String,
    val isActive: Boolean = true
)

data class TripSummary(
    val id: Long,
    val tripName: String,
    val tripPurpose: String,
    val tripCompanions: String,
    val startDate: String,
    val endDate: String
)

fun ExpenseStatus.toDbValue(): String {
    return when (this) {
        ExpenseStatus.PendingAnalysis -> "pending"
        ExpenseStatus.Reviewing -> "pending"
        ExpenseStatus.Approved -> "approved"
        ExpenseStatus.Rejected -> "rejected"
    }
}

enum class Screen(
    val label: String,
    val icon: String,
    val showInBottomBar: Boolean = true
) {
    Home("홈", "🏠"),
    History("내역", "📄"),
    Trips("출장", "🧳"),
    Stats("통계", "📊"),
    Profile("전체 메뉴", "☰"),

    ReceiptRegister("영수증 등록", "🧾", false),
    QuickRegister("빠른 등록", "⚡", false),
    AnalysisResult("분석 결과", "🤖", false),
    ReceiptDetail("상세보기", "📋", false),
    BatchAnalysis("AI 분석", "🤖", false),
    CardInfo("카드 관리", "💳", false),
    RulesInfo("회사 규정", "📌", false)
}

@Composable
fun DDalKKackApp() {
    val colorScheme = lightColorScheme(
        primary = Color(0xFF3366FF),
        secondary = Color(0xFF6B7280),
        background = Color(0xFFF6F7FB),
        surface = Color.White,
        onPrimary = Color.White,
        onBackground = Color(0xFF111827),
        onSurface = Color(0xFF111827)
    )

    MaterialTheme(
        colorScheme = colorScheme
    ) {
        Surface(
    modifier = Modifier.fillMaxSize(),
    color = MaterialTheme.colorScheme.background
) {
    var isLoggedIn by remember { mutableStateOf(false) }

    val quickReceipts = remember {
        mutableStateListOf<QuickReceipt>()
    }

    val receipts = remember {
        mutableStateListOf(
            ReceiptSummary(
                id = "sample-1",
                merchant = "스타벅스",
                amount = 15000,
                category = "식비",
                status = ExpenseStatus.Reviewing
            ),
            ReceiptSummary(
                id = "sample-2",
                merchant = "KTX",
                amount = 59800,
                category = "교통",
                status = ExpenseStatus.Approved
            ),
            ReceiptSummary(
                id = "sample-3",
                merchant = "OO식당",
                amount = 53200,
                category = "회의비",
                status = ExpenseStatus.Rejected
            )
        )
    }

    val registeredCards = remember {
        mutableStateListOf(
            RegisteredCard(
                id = 1,
                cardType = "회사카드",
                cardCompany = "신한",
                cardNumber = "5234 ****",
                isActive = true
            ),
            RegisteredCard(
                id = 2,
                cardType = "정부지원카드",
                cardCompany = "BC",
                cardNumber = "9876 ****",
                isActive = true
            )
        )
    }

    val trips = remember {
        mutableStateListOf(
            TripSummary(
                id = 1,
                tripName = "부산 고객사 방문",
                tripPurpose = "계약 협의 및 현장 점검",
                tripCompanions = "백다인, 원의재",
                startDate = "2026.05.10",
                endDate = "2026.05.12"
            ),
            TripSummary(
                id = 2,
                tripName = "서울 세미나 참석",
                tripPurpose = "AI 비용처리 세미나 참석",
                tripCompanions = "오현",
                startDate = "2026.05.18",
                endDate = "2026.05.18"
            )
        )
    }

    if (isLoggedIn) {
        MainShell(
            quickReceipts = quickReceipts,
            receipts = receipts,
            registeredCards = registeredCards,
            trips = trips,
            onLogout = {
                isLoggedIn = false
            }
        )
    } else {
        LoginScreen(
            onLoginSuccess = {
                isLoggedIn = true
            }
        )
    }
}
    }
}

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit
) {
    var userId by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .safeDrawingPadding()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "DDalKKack",
            fontSize = 34.sp,
            fontWeight = FontWeight.ExtraBold,
            color = MaterialTheme.colorScheme.primary
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "관리자가 등록한 계정으로 로그인하세요.",
            fontSize = 15.sp,
            color = Color(0xFF6B7280)
        )

        Spacer(modifier = Modifier.height(28.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            Column(
                modifier = Modifier.padding(20.dp)
            ) {
                Text(
                    text = "로그인",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = userId,
                    onValueChange = {
                        userId = it
                        errorMessage = ""
                    },
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("이메일 또는 전화번호") },
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedTextField(
                    value = password,
                    onValueChange = {
                        password = it
                        errorMessage = ""
                    },
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("비밀번호") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation()
                )

                if (errorMessage.isNotBlank()) {
                    Spacer(modifier = Modifier.height(10.dp))

                    Text(
                        text = errorMessage,
                        color = Color(0xFFD93025),
                        fontSize = 13.sp
                    )
                }

                Spacer(modifier = Modifier.height(20.dp))

                Button(
                    onClick = {
                        if (userId.isBlank() || password.isBlank()) {
                            errorMessage = "아이디와 비밀번호를 입력하세요."
                        } else {
                            onLoginSuccess()
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text(
                        text = "로그인",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(12.dp))

                Text(
                    text = "회원가입은 제공하지 않습니다.\n사용자 계정은 관리자 웹에서 사전 등록됩니다.",
                    color = Color(0xFF6B7280),
                    fontSize = 12.sp,
                    lineHeight = 18.sp
                )
            }
        }
    }
}

@Composable
fun MainShell(
    quickReceipts: SnapshotStateList<QuickReceipt>,
    receipts: SnapshotStateList<ReceiptSummary>,
    registeredCards: SnapshotStateList<RegisteredCard>,
    trips: SnapshotStateList<TripSummary>,
    onLogout: () -> Unit
) {
    var currentScreen by remember { mutableStateOf(Screen.Home) }
    var analysisTargets by remember { mutableStateOf<List<String>>(emptyList()) }
    var currentAnalysisResult by remember { mutableStateOf<AnalyzeReceiptResult?>(null) }
    var selectedReceipt by remember { mutableStateOf<ReceiptSummary?>(null) }

    Scaffold(
        bottomBar = {
            if (currentScreen.showInBottomBar) {
                NavigationBar(
                    containerColor = Color.White
                ) {
                    Screen.values()
                        .filter { it.showInBottomBar }
                        .forEach { screen ->
                            NavigationBarItem(
                                selected = currentScreen == screen,
                                onClick = { currentScreen = screen },
                                icon = {
                                    Text(
                                        text = screen.icon,
                                        fontSize = 22.sp
                                    )
                                },
                                label = {
                                    Text(screen.label)
                                }
                            )
                        }
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
        ) {
            when (currentScreen) {
                Screen.Home -> HomeScreen(
                    receipts = receipts,
                    quickReceiptCount = quickReceipts.size,
                    onMoveReceiptRegister = {
                        currentScreen = Screen.ReceiptRegister
                    },
                    onMoveQuickRegister = {
                        currentScreen = Screen.QuickRegister
                    }
                )

                Screen.ReceiptRegister -> ReceiptRegisterScreen(
                    onBack = {
                        currentScreen = Screen.Home
                    },
                    onAnalysisComplete = { result ->
                        currentAnalysisResult = result
                        currentScreen = Screen.AnalysisResult
                    }
                )

                Screen.AnalysisResult -> AnalysisResultScreen(
                    result = currentAnalysisResult,
                    onBack = {
                        currentScreen = Screen.ReceiptRegister
                    },
                    onSubmit = { result ->
                        val receipt = result.toReceiptSummary()
                        receipts.add(0, receipt)
                        currentScreen = Screen.History
                    }
                )

                Screen.ReceiptDetail -> ReceiptDetailScreen(
                    receipt = selectedReceipt,
                    onBack = {
                        currentScreen = Screen.History
                    }
                )

                Screen.QuickRegister -> QuickRegisterScreen(
                    quickReceipts = quickReceipts,
                    onRequestBatchAnalysis = { selectedPaths ->
                        analysisTargets = selectedPaths
                        currentScreen = Screen.BatchAnalysis
                    }
                )

                Screen.BatchAnalysis -> BatchAnalysisScreen(
                    selectedImagePaths = analysisTargets,
                    onBack = {
                        currentScreen = Screen.QuickRegister
                    },
                    onSaveDummyResults = { generatedReceipts ->
                        receipts.addAll(0, generatedReceipts)
                        currentScreen = Screen.History
                    }
                )

                Screen.History -> HistoryScreen(
                    receipts = receipts,
                    onOpenReceipt = { receipt ->
                        selectedReceipt = receipt
                        currentScreen = Screen.ReceiptDetail
                    }
                )

                Screen.Stats -> StatsScreen(
                    receipts = receipts
                )

                Screen.Profile -> MenuScreen(
                    onLogout = onLogout,
                    onMoveCardInfo = {
                        currentScreen = Screen.CardInfo
                    },
                    onMoveRulesInfo = {
                        currentScreen = Screen.RulesInfo
                    }
                )

                Screen.CardInfo -> CardInfoScreen(
                    registeredCards = registeredCards,
                    onBack = {
                        currentScreen = Screen.Profile
                    }
                )

                Screen.RulesInfo -> CompanyRulesScreen(
                    onBack = {
                        currentScreen = Screen.Profile
                    }
                )

                Screen.Trips -> TripsScreen(
                    trips = trips
                )
            }
        }
    }
}

@Composable
fun HomeScreen(
    receipts: List<ReceiptSummary>,
    quickReceiptCount: Int,
    onMoveReceiptRegister: () -> Unit,
    onMoveQuickRegister: () -> Unit
) {
    val totalAmount = receipts.sumOf { it.amount }
    val approvedCount = receipts.count { it.status == ExpenseStatus.Approved }
    val reviewingCount = receipts.count { it.status == ExpenseStatus.Reviewing }
    val rejectedCount = receipts.count { it.status == ExpenseStatus.Rejected }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "이번 달 대시보드",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "지출 현황과 처리 상태를 한 번에 확인합니다.",
            fontSize = 14.sp,
            color = Color(0xFF6B7280)
        )

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(26.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 3.dp)
        ) {
            Column(
                modifier = Modifier.padding(20.dp)
            ) {
                Text(
                    text = "이번 달 지출 합계",
                    fontSize = 14.sp,
                    color = Color(0xFF6B7280)
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = formatWon(totalAmount),
                    fontSize = 34.sp,
                    fontWeight = FontWeight.ExtraBold
                )

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    StatusChip(
                        label = "승인 $approvedCount",
                        status = ExpenseStatus.Approved,
                        modifier = Modifier.weight(1f)
                    )

                    StatusChip(
                        label = "검토중 $reviewingCount",
                        status = ExpenseStatus.Reviewing,
                        modifier = Modifier.weight(1f)
                    )

                    StatusChip(
                        label = "반려 $rejectedCount",
                        status = ExpenseStatus.Rejected,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            ActionCard(
                title = "영수증 등록",
                description = "촬영/업로드 후 즉시 AI 분석",
                icon = "🧾",
                modifier = Modifier.weight(1f),
                onClick = onMoveReceiptRegister
            )

            ActionCard(
                title = "빠른 등록",
                description = "분석 없이 저장 후 일괄 분석",
                icon = "⚡",
                modifier = Modifier.weight(1f),
                onClick = onMoveQuickRegister
            )
        }

        Spacer(modifier = Modifier.height(18.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(22.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFEFF4FF))
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "📥",
                    fontSize = 28.sp
                )

                Spacer(modifier = Modifier.width(12.dp))

                Column {
                    Text(
                        text = "빠른등록 보관함",
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp
                    )

                    Text(
                        text = "현재 분석 대기 영수증 $quickReceiptCount 장",
                        color = Color(0xFF4B5563),
                        fontSize = 13.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "최근 내역",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        if (receipts.isEmpty()) {
            EmptyCard(
                icon = "🧾",
                title = "아직 등록된 내역이 없습니다.",
                description = "영수증을 등록하면 최근 내역이 표시됩니다."
            )
        } else {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                receipts.take(3).forEach { receipt ->
                    ReceiptSummaryCard(receipt = receipt)
                }
            }
        }
    }
}

@Composable
fun QuickRegisterScreen(
    quickReceipts: SnapshotStateList<QuickReceipt>,
    onRequestBatchAnalysis: (List<String>) -> Unit
) {
    val context = LocalContext.current
    var message by remember { mutableStateOf("") }

    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetMultipleContents()
    ) { uris: List<Uri> ->
        if (uris.isEmpty()) return@rememberLauncherForActivityResult

        val addedReceipts = uris.mapNotNull { uri ->
            copyImageToQuickReceiptStorage(
                context = context,
                uri = uri
            )
        }

        quickReceipts.addAll(0, addedReceipts)

        message = "${addedReceipts.size}장의 영수증을 빠른등록 보관함에 저장했습니다."
    }

    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap: Bitmap? ->
        if (bitmap == null) {
            message = "촬영이 취소되었습니다."
            return@rememberLauncherForActivityResult
        }

        val addedReceipt = saveBitmapToQuickReceiptStorage(
            context = context,
            bitmap = bitmap
        )

        if (addedReceipt != null) {
            quickReceipts.add(0, addedReceipt)
            message = "촬영한 영수증을 빠른등록 보관함에 저장했습니다."
        } else {
            message = "촬영 이미지를 저장하지 못했습니다."
        }
    }

    val selectedReceipts = quickReceipts.filter { it.selected }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "빠른 등록 보관함",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "영수증을 분석 없이 저장하고, 나중에 여러 장을 한 번에 분석합니다.",
            fontSize = 14.sp,
            color = Color(0xFF6B7280),
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Button(
                onClick = {
                    galleryLauncher.launch("image/*")
                },
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(
                    text = "갤러리에서 추가",
                    fontWeight = FontWeight.Bold
                )
            }

            OutlinedButton(
                onClick = {
                    cameraLauncher.launch(null)
                },
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text("촬영하기")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "선택됨: ${selectedReceipts.size}장 / 전체 ${quickReceipts.size}장",
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    OutlinedButton(
                        onClick = {
                            val selectedIds = selectedReceipts.map { it.id }.toSet()
                            quickReceipts.removeAll { it.id in selectedIds }
                            message = "선택한 영수증을 삭제했습니다."
                        },
                        enabled = selectedReceipts.isNotEmpty(),
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(14.dp)
                    ) {
                        Text("선택 삭제")
                    }

                    Button(
                        onClick = {
                            val selectedPaths = selectedReceipts.map { it.imagePath }

                            if (selectedPaths.isEmpty()) {
                                message = "분석할 영수증을 선택하세요."
                            } else {
                                onRequestBatchAnalysis(selectedPaths)
                            }
                        },
                        enabled = selectedReceipts.isNotEmpty(),
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(14.dp)
                    ) {
                        Text("일괄 분석")
                    }
                }

                if (message.isNotBlank()) {
                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = message,
                        color = MaterialTheme.colorScheme.primary,
                        fontSize = 13.sp,
                        lineHeight = 18.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "저장된 영수증",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        if (quickReceipts.isEmpty()) {
            EmptyCard(
                icon = "📥",
                title = "보관함이 비어 있습니다.",
                description = "촬영하거나 갤러리에서 영수증 이미지를 추가해보세요."
            )
        } else {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                quickReceipts.forEach { receipt ->
                    QuickReceiptCard(
                        receipt = receipt,
                        onToggle = {
                            val index = quickReceipts.indexOfFirst { it.id == receipt.id }
                            if (index >= 0) {
                                quickReceipts[index] = quickReceipts[index].copy(
                                    selected = !quickReceipts[index].selected
                                )
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun BatchAnalysisScreen(
    selectedImagePaths: List<String>,
    onBack: () -> Unit,
    onSaveDummyResults: (List<ReceiptSummary>) -> Unit
) {
    val dummyResults = remember(selectedImagePaths) {
        generateDummyReceiptsFromPaths(selectedImagePaths)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "AI 일괄 분석",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "선택된 영수증 이미지를 AI 분석 모듈로 전달하는 더미 화면입니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "분석 대상",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(10.dp))

                Text(
                    text = "${selectedImagePaths.size}장의 영수증 이미지",
                    color = MaterialTheme.colorScheme.primary,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.ExtraBold
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "예상 처리 단계",
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(8.dp))

                AnalysisStep("1", "이미지 업로드 또는 경로 전달")
                AnalysisStep("2", "Gemini/OCR 기반 영수증 정보 추출")
                AnalysisStep("3", "가맹점, 금액, 날짜, 카드 정보 구조화")
                AnalysisStep("4", "RAG/Rule 기반 규정 검토 모듈로 전달")
                AnalysisStep("5", "분석 결과를 사용자 확인 화면으로 반환")
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        Text(
            text = "더미 분석 결과",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        Column(
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            dummyResults.forEach { receipt ->
                ReceiptSummaryCard(receipt = receipt)
            }
        }

        Spacer(modifier = Modifier.height(22.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text("뒤로")
            }

            Button(
                onClick = {
                    onSaveDummyResults(dummyResults)
                },
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(
                    text = "내역에 저장",
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun AnalysisStep(
    number: String,
    text: String
) {
    Row(
        modifier = Modifier.padding(vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(28.dp)
                .clip(RoundedCornerShape(999.dp))
                .background(Color(0xFFEFF4FF)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = number,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp
            )
        }

        Spacer(modifier = Modifier.width(10.dp))

        Text(
            text = text,
            color = Color(0xFF374151),
            fontSize = 14.sp
        )
    }
}

fun generateDummyReceiptsFromPaths(
    imagePaths: List<String>
): List<ReceiptSummary> {
    val merchants = listOf("스타벅스", "김밥천국", "KTX", "OO식당", "편의점")
    val categories = listOf("식비", "회의비", "교통", "복리후생", "기타")

    return imagePaths.mapIndexed { index, _ ->
        ReceiptSummary(
            id = "ai-dummy-${System.currentTimeMillis()}-$index",
            merchant = merchants[index % merchants.size],
            amount = 8000 + index * 7300,
            category = categories[index % categories.size],
            status = ExpenseStatus.Reviewing
        )
    }
}

@Composable
fun HistoryScreen(
    receipts: List<ReceiptSummary>,
    onOpenReceipt: (ReceiptSummary) -> Unit
) {
    var selectedStatus by remember { mutableStateOf<ExpenseStatus?>(null) }

    val filteredReceipts = if (selectedStatus == null) {
        receipts
    } else {
        receipts.filter { it.status == selectedStatus }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "정산 내역",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "분석 및 제출된 지출 내역을 확인합니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp
        )

        Spacer(modifier = Modifier.height(18.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            FilterButton(
                label = "전체",
                selected = selectedStatus == null,
                modifier = Modifier.weight(1f),
                onClick = { selectedStatus = null }
            )

            ExpenseStatus.values().forEach { status ->
                FilterButton(
                    label = status.label,
                    selected = selectedStatus == status,
                    modifier = Modifier.weight(1f),
                    onClick = { selectedStatus = status }
                )
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        if (filteredReceipts.isEmpty()) {
            EmptyCard(
                icon = "📄",
                title = "표시할 내역이 없습니다.",
                description = "조건에 맞는 지출 내역이 없습니다."
            )
        } else {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                filteredReceipts.forEach { receipt ->
                    ReceiptSummaryCard(
                        receipt = receipt,
                        onClick = {
                            onOpenReceipt(receipt)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun StatsScreen(
    receipts: List<ReceiptSummary>
) {
    val totalAmount = receipts.sumOf { it.amount }
    val foodAmount = receipts.filter { it.category.contains("식") || it.category.contains("회의") }.sumOf { it.amount }
    val transportAmount = receipts.filter { it.category.contains("교통") }.sumOf { it.amount }
    val etcAmount = (totalAmount - foodAmount - transportAmount).coerceAtLeast(0)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "통계",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "이번 달 지출 흐름을 요약합니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "이번 달 총 지출",
                    color = Color(0xFF6B7280),
                    fontSize = 14.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = formatWon(totalAmount),
                    fontSize = 32.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        Text(
            text = "카테고리별 지출",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        StatBar(
            label = "식비/회의비",
            amount = foodAmount,
            total = totalAmount
        )

        StatBar(
            label = "교통",
            amount = transportAmount,
            total = totalAmount
        )

        StatBar(
            label = "기타",
            amount = etcAmount,
            total = totalAmount
        )

        Spacer(modifier = Modifier.height(18.dp))

        Text(
            text = "상태별 처리 현황",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(12.dp))

        Column(
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            ExpenseStatus.values().forEach { status ->
                val count = receipts.count { it.status == status }

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(18.dp),
                    colors = CardDefaults.cardColors(containerColor = status.background)
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = status.label,
                            color = status.color,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.weight(1f)
                        )

                        Text(
                            text = "${count}건",
                            color = status.color,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MenuScreen(
    onLogout: () -> Unit,
    onMoveCardInfo: () -> Unit,
    onMoveRulesInfo: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "전체 메뉴",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(18.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "테스트 사용자",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = "test@ddalkkack.com",
                    color = Color(0xFF6B7280),
                    fontSize = 14.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "직급: 사원",
                    color = Color(0xFF374151),
                    fontSize = 14.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        ProfileMenuCard(
            icon = "👤",
            title = "내 정보 관리",
            description = "이름, 직급, 연락처 등 사용자 정보를 확인합니다.",
            onClick = {
                // TODO: 내 정보 관리 화면 연결
            }
        )

        ProfileMenuCard(
            icon = "💳",
            title = "카드 관리",
            description = "등록된 카드 정보를 확인합니다.",
            onClick = onMoveCardInfo
        )

        ProfileMenuCard(
            icon = "📌",
            title = "규정 확인",
            description = "회사 경비 규정과 카드별 규정을 확인합니다.",
            onClick = onMoveRulesInfo
        )

        Spacer(modifier = Modifier.height(20.dp))

        OutlinedButton(
            onClick = onLogout,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text(
                text = "로그아웃",
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun ReceiptRegisterScreen(
    onBack: () -> Unit,
    onAnalysisComplete: (AnalyzeReceiptResult) -> Unit
) {
    val context = LocalContext.current
    var message by remember { mutableStateOf("") }

    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri == null) {
            message = "이미지 선택이 취소되었습니다."
            return@rememberLauncherForActivityResult
        }

        val quickReceipt = copyImageToQuickReceiptStorage(
            context = context,
            uri = uri
        )

        if (quickReceipt != null) {
            val result = createDummyAnalysisResult(quickReceipt.imagePath)
            onAnalysisComplete(result)
        } else {
            message = "이미지를 저장하지 못했습니다."
        }
    }

    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap: Bitmap? ->
        if (bitmap == null) {
            message = "촬영이 취소되었습니다."
            return@rememberLauncherForActivityResult
        }

        val quickReceipt = saveBitmapToQuickReceiptStorage(
            context = context,
            bitmap = bitmap
        )

        if (quickReceipt != null) {
            val result = createDummyAnalysisResult(quickReceipt.imagePath)
            onAnalysisComplete(result)
        } else {
            message = "촬영 이미지를 저장하지 못했습니다."
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "영수증 등록",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "영수증을 촬영하거나 업로드하면 즉시 AI 분석을 진행합니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(22.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(20.dp)
            ) {
                Text(
                    text = "등록 방식 선택",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(14.dp))

                Button(
                    onClick = {
                        cameraLauncher.launch(null)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text(
                        text = "촬영하기",
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(10.dp))

                OutlinedButton(
                    onClick = {
                        galleryLauncher.launch("image/*")
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text("갤러리에서 업로드")
                }

                if (message.isNotBlank()) {
                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = message,
                        color = Color(0xFFD93025),
                        fontSize = 13.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(22.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFEFF4FF))
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "빠른등록과의 차이",
                    fontWeight = FontWeight.Bold,
                    fontSize = 17.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "영수증 등록은 이미지 선택 직후 AI 분석으로 이동합니다.\n빠른등록은 분석 없이 보관함에 저장한 뒤 나중에 일괄 분석합니다.",
                    color = Color(0xFF374151),
                    fontSize = 13.sp,
                    lineHeight = 20.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(22.dp))

        OutlinedButton(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("돌아가기")
        }
    }
}

@Composable
fun AnalysisResultScreen(
    result: AnalyzeReceiptResult?,
    onBack: () -> Unit,
    onSubmit: (AnalyzeReceiptResult) -> Unit
) {
    if (result == null) {
        EmptyStateWithBack(
            title = "분석 결과가 없습니다.",
            description = "다시 영수증을 등록해주세요.",
            onBack = onBack
        )
        return
    }

    var isEditing by remember { mutableStateOf(false) }
    var merchant by remember { mutableStateOf(result.merchant) }
    var amountText by remember { mutableStateOf(result.amount.toString()) }
    var date by remember { mutableStateOf(result.date) }
    var time by remember { mutableStateOf(result.time) }
    var category by remember { mutableStateOf(result.category) }
    var cardType by remember { mutableStateOf(result.cardType) }
    var cardCompany by remember { mutableStateOf(result.cardCompany) }
    var cardNumber by remember { mutableStateOf(result.cardNumber) }
    var purpose by remember { mutableStateOf(result.purpose) }
    var participants by remember { mutableStateOf(result.participants) }

    val policyResult = validateReceiptPolicyResult(
    category = category,
    amount = amountText.toIntOrNull() ?: result.amount,
    cardType = cardType,
    purpose = purpose,
    participants = participants,
    time = time,
    tripId = result.tripId
    )

    val editedResult = result.copy(
    merchant = merchant,
    amount = amountText.toIntOrNull() ?: result.amount,
    date = date,
    time = time,
    category = category,
    cardType = cardType,
    cardCompany = cardCompany,
    cardNumber = cardNumber,
    purpose = purpose,
    participants = participants,
    warnings = policyResult.warnings,
    rejectionReasons = policyResult.rejectionReasons,
    status = policyResult.status
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "AI 분석 결과",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "AI가 추출한 정보를 확인하고 필요한 경우 수정하세요.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "추출 정보",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(14.dp))

                if (isEditing) {
                    OutlinedTextField(
                        value = merchant,
                        onValueChange = { merchant = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("가맹점") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = amountText,
                        onValueChange = { amountText = it.filter { ch -> ch.isDigit() } },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("금액") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = date,
                        onValueChange = { date = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("날짜") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = time,
                        onValueChange = { time = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("시간") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = category,
                        onValueChange = { category = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("카테고리") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = cardType,
                        onValueChange = { cardType = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("카드 종류") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = cardCompany,
                        onValueChange = { cardCompany = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("카드사") },
                        placeholder = { Text("예: 신한, 국민, 현대") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = cardNumber,
                        onValueChange = { cardNumber = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("카드 번호 일부") },
                        placeholder = { Text("예: 5234 ****") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = purpose,
                        onValueChange = { purpose = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("사용 목적") },
                        placeholder = { Text("예: 캡스톤 회의 후 팀 회의비") }
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = participants,
                        onValueChange = { participants = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("참여자") },
                        placeholder = { Text("예: 백다인, 오현, 원의재") }
                    )

                } else {
                    AnalysisField("가맹점", merchant)
                    AnalysisField("금액", formatWon(amountText.toIntOrNull() ?: 0))
                    AnalysisField("날짜", date)
                    AnalysisField("시간", time)
                    AnalysisField("카테고리", category)
                    AnalysisField("카드사", cardCompany.ifBlank { "미인식" })
                    AnalysisField("카드 번호", cardNumber.ifBlank { "미인식" })
                    AnalysisField("사용 목적", purpose.ifBlank { "미입력" })
                    AnalysisField("참여자", participants.ifBlank { "미입력" })
                    AnalysisField("카드 종류", cardType)
                    AnalysisField("처리 상태", result.status.label)
                }
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        WarningSection(warnings = editedResult.warnings)

        Spacer(modifier = Modifier.height(12.dp))

        RejectionReasonSection(reasons = editedResult.rejectionReasons)

        Spacer(modifier = Modifier.height(22.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text("뒤로")
            }

            OutlinedButton(
                onClick = {
                    isEditing = !isEditing
                },
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(if (isEditing) "수정 완료" else "수정")
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        Button(
            onClick = {
                onSubmit(editedResult)
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text(
                text = "제출하기",
                fontWeight = FontWeight.Bold
            )
        }
    }
}



@Composable
fun AppHeader() {
    Text(
        text = "DDalKKack",
        fontSize = 26.sp,
        fontWeight = FontWeight.ExtraBold
    )
}

@Composable
fun ReceiptDetailScreen(
    receipt: ReceiptSummary?,
    onBack: () -> Unit
) {
    if (receipt == null) {
        EmptyStateWithBack(
            title = "상세 내역이 없습니다.",
            description = "다시 내역을 선택해주세요.",
            onBack = onBack
        )
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "지출 상세보기",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "영수증 이미지, 분석 결과, 규정 검증 결과를 확인합니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = receipt.merchant,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.ExtraBold
                )

                Spacer(modifier = Modifier.height(8.dp))

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(999.dp))
                        .background(receipt.status.background)
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = receipt.status.label,
                        color = receipt.status.color,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.sp
                    )
                }

                Spacer(modifier = Modifier.height(18.dp))

                AnalysisField("금액", formatWon(receipt.amount))
                AnalysisField("날짜", receipt.date.ifBlank { "미기록" })
                AnalysisField("시간", receipt.time.ifBlank { "미기록" })
                AnalysisField("카테고리", receipt.category)
                AnalysisField("카드 종류", receipt.cardType.ifBlank { "미분류" })
                AnalysisField("카드사", receipt.cardCompany.ifBlank { "미기록" })
                AnalysisField("카드 번호", receipt.cardNumber.ifBlank { "미기록" })
                AnalysisField("사용 목적", receipt.purpose.ifBlank { "미입력" })
                AnalysisField("참여자", receipt.participants.ifBlank { "미입력" })
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(22.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(
                modifier = Modifier.padding(18.dp)
            ) {
                Text(
                    text = "영수증 이미지",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(10.dp))

                Text(
                    text = receipt.imagePath ?: "이미지 경로 없음",
                    color = Color(0xFF6B7280),
                    fontSize = 12.sp,
                    lineHeight = 18.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        WarningSection(warnings = receipt.warnings)

        Spacer(modifier = Modifier.height(12.dp))

        RejectionReasonSection(reasons = receipt.rejectionReasons)

        Spacer(modifier = Modifier.height(22.dp))

        OutlinedButton(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("돌아가기")
        }
    }
}

@Composable
fun AnalysisField(
    label: String,
    value: String
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 7.dp)
    ) {
        Text(
            text = label,
            color = Color(0xFF6B7280),
            fontSize = 12.sp
        )

        Spacer(modifier = Modifier.height(3.dp))

        Text(
            text = value,
            color = Color(0xFF111827),
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun WarningSection(
    warnings: List<String>
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (warnings.isEmpty()) Color(0xFFE8F5E9) else Color(0xFFFFF7ED)
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(18.dp)
        ) {
            Text(
                text = if (warnings.any { it.contains("반려") }) {
                    "반려 사유"
                } else {
                    "규정 검증 결과"
                },
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(10.dp))

            if (warnings.isEmpty()) {
                Text(
                    text = "현재 감지된 경고가 없습니다.",
                    color = Color(0xFF0F9D58),
                    fontSize = 14.sp
                )
            } else {
                warnings.forEach { warning ->
                    Text(
                        text = "• $warning",
                        color = Color(0xFF92400E),
                        fontSize = 14.sp,
                        lineHeight = 20.sp,
                        modifier = Modifier.padding(bottom = 5.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun EmptyStateWithBack(
    title: String,
    description: String,
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(22.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        EmptyCard(
            icon = "⚠️",
            title = title,
            description = description
        )

        Spacer(modifier = Modifier.height(18.dp))

        OutlinedButton(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("돌아가기")
        }
    }
}

fun createDummyAnalysisResult(
    imagePath: String
): AnalyzeReceiptResult {
    return AnalyzeReceiptResult(
        merchant = "스타벅스 광운대점",
        amount = 15000,
        date = "2026.05.01",
        time = "14:30",
        category = "회의비",
        cardType = "회사카드",
        cardCompany = "신한",
        cardNumber = "5234 ****",
        purpose = "",
        participants = "",
        tripId = null,
        status = ExpenseStatus.Reviewing,
        warnings = listOf(
            "회의비로 처리하려면 사용 목적 입력이 필요합니다.",
            "참여자 정보가 누락되어 검토중 상태로 분류되었습니다."
        ),
        imagePath = imagePath
    )
}

fun AnalyzeReceiptResult.toReceiptSummary(): ReceiptSummary {
    return ReceiptSummary(
        id = "receipt_${System.currentTimeMillis()}",
        merchant = merchant,
        amount = amount,
        category = category,
        status = status,
        date = date,
        time = time,
        cardType = cardType,
        cardCompany = cardCompany,
        cardNumber = cardNumber,
        purpose = purpose,
        participants = participants,
        tripId = tripId,
        imagePath = imagePath,
        warnings = warnings,
        rejectionReasons = rejectionReasons
    )
}

fun validateReceiptPolicyResult(
    category: String,
    amount: Int,
    cardType: String,
    purpose: String,
    participants: String,
    time: String,
    tripId: Long?
): PolicyValidationResult {
    val warnings = mutableListOf<String>()
    val rejectionReasons = mutableListOf<String>()

    if (
        cardType == "회사카드" &&
        category.contains("식") &&
        amount > 15000
    ) {
        warnings.add("회사카드 일반 식대는 1인 1식 기준 15,000원을 초과할 수 있습니다.")
    }

    if (
        (category.contains("회의") || category.contains("접대")) &&
        purpose.isBlank()
    ) {
        warnings.add("회의비/접대비로 처리하려면 사용 목적 입력이 필요합니다.")
    }

    if (
        (category.contains("회의") || category.contains("접대")) &&
        participants.isBlank()
    ) {
        warnings.add("회의비/접대비로 처리하려면 참여자 정보 입력이 필요합니다.")
    }

    if (
        cardType == "정부지원카드" &&
        purpose.isBlank()
    ) {
        warnings.add("정부지원카드는 과제 관련 사용 목적을 반드시 입력해야 합니다.")
    }

    if (
        cardType == "정부지원카드" &&
        (category.contains("접대") || category.contains("회식"))
    ) {
        rejectionReasons.add("정부지원카드는 접대비 또는 회식비로 사용할 수 없습니다.")
    }

    if (
        category.contains("주류") ||
        category.contains("담배") ||
        category.contains("유흥")
    ) {
        rejectionReasons.add("주류, 담배, 유흥업소 관련 지출은 비용 처리할 수 없습니다.")
    }

    if (
        (category.contains("출장") || category.contains("숙박")) &&
        tripId == null
    ) {
        warnings.add("출장/숙박 관련 지출은 출장 정보와 연결하는 것이 권장됩니다.")
    }

    val status = when {
        rejectionReasons.isNotEmpty() -> ExpenseStatus.Rejected
        warnings.isNotEmpty() -> ExpenseStatus.Reviewing
        else -> ExpenseStatus.Approved
    }

    return PolicyValidationResult(
        status = status,
        warnings = warnings,
        rejectionReasons = rejectionReasons
    )
}

@Composable
fun StatusChip(
    label: String,
    status: ExpenseStatus,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(status.background)
            .padding(vertical = 10.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = status.color,
            fontWeight = FontWeight.Bold,
            fontSize = 13.sp
        )
    }
}

@Composable
fun ActionCard(
    title: String,
    description: String,
    icon: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Card(
        modifier = modifier
            .height(145.dp)
            .clickable { onClick() },
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = icon,
                fontSize = 28.sp
            )

            Column {
                Text(
                    text = title,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = description,
                    color = Color(0xFF6B7280),
                    fontSize = 12.sp,
                    lineHeight = 17.sp
                )
            }
        }
    }
}

@Composable
fun ReceiptSummaryCard(
    receipt: ReceiptSummary,
    onClick: () -> Unit = {}
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color(0xFFEFF4FF)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "🧾",
                    fontSize = 24.sp
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = receipt.merchant,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = receipt.category,
                    color = Color(0xFF6B7280),
                    fontSize = 13.sp
                )
            }

            Column(
                horizontalAlignment = Alignment.End
            ) {
                Text(
                    text = formatWon(receipt.amount),
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 15.sp
                )

                Spacer(modifier = Modifier.height(6.dp))

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(999.dp))
                        .background(receipt.status.background)
                        .padding(horizontal = 10.dp, vertical = 5.dp)
                ) {
                    Text(
                        text = receipt.status.label,
                        color = receipt.status.color,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
fun QuickReceiptCard(
    receipt: QuickReceipt,
    onToggle: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onToggle() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (receipt.selected) {
                Color(0xFFEFF4FF)
            } else {
                Color.White
            }
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = receipt.selected,
                onCheckedChange = { onToggle() }
            )

            Spacer(modifier = Modifier.width(8.dp))

            Box(
                modifier = Modifier
                    .size(54.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color(0xFFF3F4F6)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "🧾",
                    fontSize = 24.sp
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = receipt.fileName,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = receipt.createdAt,
                    color = Color(0xFF6B7280),
                    fontSize = 12.sp
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = receipt.imagePath,
                    color = Color(0xFF9CA3AF),
                    fontSize = 10.sp,
                    maxLines = 1
                )
            }
        }
    }
}

@Composable
fun FilterButton(
    label: String,
    selected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .height(42.dp)
            .clip(RoundedCornerShape(999.dp))
            .background(
                if (selected) {
                    MaterialTheme.colorScheme.primary
                } else {
                    Color.White
                }
            )
            .border(
                width = 1.dp,
                color = if (selected) {
                    MaterialTheme.colorScheme.primary
                } else {
                    Color(0xFFE5E7EB)
                },
                shape = RoundedCornerShape(999.dp)
            )
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = if (selected) Color.White else Color(0xFF374151),
            fontWeight = FontWeight.Bold,
            fontSize = 13.sp
        )
    }
}

@Composable
fun StatBar(
    label: String,
    amount: Int,
    total: Int
) {
    val fraction = if (total == 0) {
        0f
    } else {
        (amount.toFloat() / total.toFloat()).coerceIn(0f, 1f)
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 10.dp),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = label,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )

                Text(
                    text = formatWon(amount),
                    color = Color(0xFF6B7280),
                    fontSize = 13.sp
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(10.dp)
                    .clip(RoundedCornerShape(999.dp))
                    .background(Color(0xFFE5E7EB))
            ) {
                if (fraction > 0f) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(fraction)
                            .height(10.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(MaterialTheme.colorScheme.primary)
                    )
                }
            }
        }
    }
}

@Composable
fun ProfileMenuCard(
    icon: String,
    title: String,
    description: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 10.dp)
            .clickable { onClick() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = icon,
                fontSize = 28.sp
            )

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = description,
                    color = Color(0xFF6B7280),
                    fontSize = 12.sp,
                    lineHeight = 17.sp
                )
            }

            Text(
                text = "›",
                fontSize = 28.sp,
                color = Color(0xFF9CA3AF)
            )
        }
    }
}

@Composable
fun CardInfoScreen(
    registeredCards: List<RegisteredCard>,
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "카드 관리",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "등록된 카드 정보를 확인합니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        if (registeredCards.isEmpty()) {
            EmptyCard(
                icon = "💳",
                title = "등록된 카드가 없습니다.",
                description = "카드 등록 후 이용할 수 있습니다."
            )
        } else {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                registeredCards.forEach { card ->
                    RegisteredCardItem(card = card)
                }
            }
        }

        Spacer(modifier = Modifier.height(22.dp))

        OutlinedButton(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("돌아가기")
        }
    }
}

@Composable
fun RegisteredCardItem(
    card: RegisteredCard
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = card.cardType,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "${card.cardCompany} · ${card.cardNumber}",
                color = MaterialTheme.colorScheme.primary,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = if (card.isActive) "사용 가능" else "사용 중지",
                color = if (card.isActive) Color(0xFF0F9D58) else Color(0xFFD93025),
                fontSize = 13.sp
            )
        }
    }
}

@Composable
fun CardInfoItem(
    cardName: String,
    cardCompany: String,
    maskedNumber: String,
    description: String
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 10.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = cardName,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "$cardCompany · $maskedNumber",
                color = MaterialTheme.colorScheme.primary,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = description,
                color = Color(0xFF6B7280),
                fontSize = 13.sp,
                lineHeight = 19.sp
            )
        }
    }
}

@Composable
fun TripsScreen(
    trips: List<TripSummary>
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "출장",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "출장 정보와 관련 지출을 연결하기 위한 화면입니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        if (trips.isEmpty()) {
            EmptyCard(
                icon = "🧳",
                title = "등록된 출장이 없습니다.",
                description = "출장 등록 기능은 다음 단계에서 연결합니다."
            )
        } else {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                trips.forEach { trip ->
                    TripCard(trip = trip)
                }
            }
        }
    }
}

@Composable
fun TripCard(
    trip: TripSummary
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(18.dp)
        ) {
            Text(
                text = trip.tripName,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "${trip.startDate} ~ ${trip.endDate}",
                color = MaterialTheme.colorScheme.primary,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(10.dp))

            AnalysisField("출장 목적", trip.tripPurpose)
            AnalysisField("동행인", trip.tripCompanions.ifBlank { "없음" })
        }
    }
}

@Composable
fun CompanyRulesScreen(
    onBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(22.dp)
    ) {
        AppHeader()

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "회사 규정 확인",
            fontSize = 28.sp,
            fontWeight = FontWeight.ExtraBold
        )

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "경비 처리 전 확인해야 할 주요 규정입니다.",
            color = Color(0xFF6B7280),
            fontSize = 14.sp,
            lineHeight = 20.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        RuleInfoItem(
            title = "회사카드 식대",
            description = "일반 식대는 1인 1식 기준 최대 15,000원까지 인정됩니다. 야근 식대는 오후 8시 이후 1인 기준 최대 20,000원까지 인정됩니다."
        )

        RuleInfoItem(
            title = "교통비",
            description = "외근, 출장 등 업무 목적 이동 시 지원됩니다. 대중교통은 실비 정산하며, 택시는 야간 업무 또는 대중교통 이용이 어려운 경우 인정됩니다."
        )

        RuleInfoItem(
            title = "회식비",
            description = "팀 회식 및 조직 활성화 목적에 한하여 지원됩니다. 팀장 이상 사전 승인 후 진행 가능하며, 1인 기준 최대 50,000원까지 인정됩니다."
        )

        RuleInfoItem(
            title = "접대비",
            description = "거래처 미팅, 고객 응대, 사업 협의 등 업무 목적에 한하여 사용 가능합니다. 참석자, 사용 목적, 거래처 정보를 기재해야 합니다."
        )

        RuleInfoItem(
            title = "정부지원카드",
            description = "정부지원카드는 승인된 과제 목적에 한하여 사용 가능합니다. 회의 목적과 참석자 작성이 필요하며, 주류·유흥업소·개인 용도 사용은 제한됩니다."
        )

        RuleInfoItem(
            title = "정부지원카드 회의비/식대",
            description = "과제 관련 회의 및 업무 협의 목적에 한해 인정됩니다. 일반 회의 식대는 1인당 30,000원 이하, 외부 전문가 포함 시 50,000원 이하를 권장합니다."
        )

        RuleInfoItem(
            title = "출장비",
            description = "출장 관련 지출은 출장 ID 또는 관련 업무와 연결해야 합니다. 출장 여부가 등록되지 않은 경우 일반 지출 규정을 우선 적용합니다."
        )

        RuleInfoItem(
            title = "금지 가능 항목",
            description = "담배, 주류, 유흥업소, 개인 물품, 사적 여행 경비, 의류 및 사치품 등은 경고 또는 반려 대상으로 분류될 수 있습니다."
        )

        Spacer(modifier = Modifier.height(22.dp))

        OutlinedButton(
            onClick = onBack,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("돌아가기")
        }
    }
}

@Composable
fun RuleInfoItem(
    title: String,
    description: String
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 10.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = title,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = description,
                color = Color(0xFF6B7280),
                fontSize = 13.sp,
                lineHeight = 19.sp
            )
        }
    }
}

@Composable
fun EmptyCard(
    icon: String,
    title: String,
    description: String
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = icon,
                fontSize = 38.sp
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = title,
                fontWeight = FontWeight.Bold,
                fontSize = 16.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = description,
                color = Color(0xFF6B7280),
                fontSize = 13.sp,
                textAlign = TextAlign.Center,
                lineHeight = 19.sp,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

fun copyImageToQuickReceiptStorage(
    context: Context,
    uri: Uri
): QuickReceipt? {
    return try {
        val directory = File(context.filesDir, "quick_receipts")

        if (!directory.exists()) {
            directory.mkdirs()
        }

        val fileName = "quick_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(8)}.jpg"
        val outputFile = File(directory, fileName)

        context.contentResolver.openInputStream(uri)?.use { inputStream ->
            FileOutputStream(outputFile).use { outputStream ->
                inputStream.copyTo(outputStream)
            }
        } ?: return null

        QuickReceipt(
            id = UUID.randomUUID().toString(),
            imagePath = outputFile.absolutePath,
            fileName = fileName,
            createdAt = currentTimeText()
        )
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}


fun saveBitmapToQuickReceiptStorage(
    context: Context,
    bitmap: Bitmap
): QuickReceipt? {
    return try {
        val directory = File(context.filesDir, "quick_receipts")

        if (!directory.exists()) {
            directory.mkdirs()
        }

        val fileName = "camera_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(8)}.jpg"
        val outputFile = File(directory, fileName)

        FileOutputStream(outputFile).use { outputStream ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 92, outputStream)
        }

        QuickReceipt(
            id = UUID.randomUUID().toString(),
            imagePath = outputFile.absolutePath,
            fileName = fileName,
            createdAt = currentTimeText()
        )
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}
fun currentTimeText(): String {
    val formatter = SimpleDateFormat("yyyy.MM.dd HH:mm", Locale.KOREA)
    return formatter.format(Date())
}

fun formatWon(amount: Int): String {
    return "%,d원".format(amount)
}

@Composable
fun RejectionReasonSection(
    reasons: List<String>
) {
    if (reasons.isEmpty()) return

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFFFEBEE)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(18.dp)
        ) {
            Text(
                text = "반려 사유",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFFD93025)
            )

            Spacer(modifier = Modifier.height(10.dp))

            reasons.forEach { reason ->
                Text(
                    text = "• $reason",
                    color = Color(0xFFD93025),
                    fontSize = 14.sp,
                    lineHeight = 20.sp,
                    modifier = Modifier.padding(bottom = 5.dp)
                )
            }
        }
    }
}