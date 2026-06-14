import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/core/utils/image_helper.dart';
import 'package:sevaku/providers/data_providers.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:sevaku/models/booking_model.dart';
import 'package:sevaku/core/widgets/app_empty_state.dart';
import 'package:sevaku/core/widgets/app_error_state.dart';

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = ref.watch(isCustomerProvider);
    final bookingsAsync = ref.watch(isCustomer ? customerBookingsProvider : workerBookingsProvider);

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final activeBookings = bookings.where((b) => b.status != 'completed' && b.status != 'cancelled').toList();
          final pastBookings = bookings.where((b) => b.status == 'completed' || b.status == 'cancelled').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingsList(
                bookings: activeBookings,
                emptyMessage: 'No active bookings',
                emptyIcon: Icons.calendar_today_outlined,
                onRefresh: () async {
                  ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
                  await ref.read(isCustomer ? customerBookingsProvider.future : workerBookingsProvider.future);
                },
              ),
              _BookingsList(
                bookings: pastBookings,
                emptyMessage: 'No past bookings',
                emptyIcon: Icons.history,
                onRefresh: () async {
                  ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
                  await ref.read(isCustomer ? customerBookingsProvider.future : workerBookingsProvider.future);
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: BrandColors.primaryGreen)),
        error: (err, _) => AppErrorState(
          message: 'Error loading bookings',
          onRetry: () {
            ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;

  const _BookingsList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        color: BrandColors.primaryGreen,
        backgroundColor: BrandColors.lightGray,
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: AppEmptyState(
              icon: emptyIcon,
              title: emptyMessage,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: BrandColors.primaryGreen,
      backgroundColor: BrandColors.lightGray,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _BookingCard(booking: bookings[index])
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn()
              .slideY(begin: 0.05);
        },
      ),
    );
  }
}

class _BookingCard extends ConsumerStatefulWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  ConsumerState<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<_BookingCard> {
  bool _isStartingChat = false;
  bool _isProcessingPayment = false;
  bool _isGettingPayment = false;
  bool _isUpdatingStatus = false;

  Future<void> _updateStatus(String status) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    
    try {
      final isCustomer = ref.read(isCustomerProvider);
      await ref.read(firestoreServiceProvider).updateBookingStatus(widget.booking.id, status);
      
      // Invalidate the bookings list so it refreshes immediately
      ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking status: $e'), 
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _processPayment() async {
    if (_isProcessingPayment) return;
    setState(() => _isProcessingPayment = true);
    
    try {
      // Mock payment gateway delay
      await Future.delayed(const Duration(seconds: 2));
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.updatePaymentStatus(widget.booking.id, 'paid');
      await firestore.updateBookingStatus(widget.booking.id, 'completed');
      
      final isCustomer = ref.read(isCustomerProvider);
      ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Job completed.'), 
            backgroundColor: BrandColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'), 
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _getPayment() async {
    if (_isGettingPayment) return;
    setState(() => _isGettingPayment = true);
    
    try {
      // Mock QR scanning delay / future placeholder for QR overlay
      await Future.delayed(const Duration(seconds: 2));
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.updatePaymentStatus(widget.booking.id, 'paid');
      await firestore.updateBookingStatus(widget.booking.id, 'completed');
      
      final isCustomer = ref.read(isCustomerProvider);
      ref.invalidate(isCustomer ? customerBookingsProvider : workerBookingsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment received via QR! Job completed.'), 
            backgroundColor: BrandColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to receive payment. Please try again.'), 
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingPayment = false);
    }
  }

  Future<void> _openChat() async {
    if (_isStartingChat) return;
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final isCustomer = currentUser.role == 'customer';
    
    final otherUid = isCustomer ? widget.booking.workerId : widget.booking.customerId;
    final otherName = isCustomer ? widget.booking.workerName : widget.booking.customerName;
    final otherPhoto = isCustomer ? widget.booking.workerPhoto : widget.booking.customerPhoto;

    setState(() => _isStartingChat = true);
    try {
      final chatId = await ref.read(firestoreServiceProvider).getOrCreateChat(
            currentUser.uid,
            otherUid,
            otherName,
            otherPhoto,
            user1Name: currentUser.name,
            user1Photo: currentUser.photoUrl,
          );
      if (mounted) context.push('/chat/$chatId');
    } catch (e) {
      print('Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();
    final currentUser = ref.watch(currentUserProvider);
    final isCustomer = currentUser?.role == 'customer';
    
    final displayPhoto = isCustomer ? widget.booking.workerPhoto : widget.booking.customerPhoto;
    final displayName = isCustomer ? widget.booking.workerName : widget.booking.customerName;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.lightGray,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: BrandColors.surfaceLight,
                backgroundImage: resolveImageProvider(displayPhoto),
                child: resolveImageProvider(displayPhoto) == null
                    ? const Icon(Icons.person, size: 22, color: BrandColors.textMuted)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName, 
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.booking.category.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: BrandColors.divider, height: 1),
          ),

          // Description
          Text(
            widget.booking.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: BrandColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Details row
          Row(
            children: [
              _DetailChip(Icons.calendar_today, _formatDate(widget.booking.scheduledDate)),
              const SizedBox(width: 12),
              if (widget.booking.address != null)
                Expanded(
                  child: _DetailChip(Icons.location_on_outlined, widget.booking.address!),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${widget.booking.totalAmount.toInt()}',
                    style: AppTextStyles.price.copyWith(fontSize: 16),
                  ),
                  Text(
                    widget.booking.paymentStatus == 'paid' ? 'Paid' : 'Unpaid',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.booking.paymentStatus == 'paid' 
                          ? BrandColors.primaryGreen 
                          : BrandColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action buttons for active bookings
          if (widget.booking.status != 'completed' && widget.booking.status != 'cancelled') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (!isCustomer && widget.booking.status == 'pending')
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: _isStartingChat ? null : _openChat,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: BrandColors.white,
                        side: const BorderSide(color: BrandColors.divider),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isStartingChat 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.primaryGreen)
                            )
                          : const Icon(Icons.chat_bubble_outline, size: 18),
                    ),
                  ),
                  
                if (isCustomer || widget.booking.status != 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isStartingChat ? null : _openChat,
                      icon: _isStartingChat 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.primaryGreen)
                            )
                          : const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Chat', style: TextStyle(fontFamily: 'Lexend', fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BrandColors.white,
                        side: const BorderSide(color: BrandColors.divider),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                if (!isCustomer && widget.booking.status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUpdatingStatus ? null : () => _updateStatus('cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BrandColors.error,
                        side: const BorderSide(color: BrandColors.error, width: 1),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Decline', style: TextStyle(fontFamily: 'Lexend', fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdatingStatus ? null : () => _updateStatus('accepted'),
                      child: _isUpdatingStatus
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.shadeBlack),
                            )
                          : const Text('Accept', style: TextStyle(fontFamily: 'Lexend', fontSize: 13)),
                    ),
                  ),
                ],
                if (isCustomer || widget.booking.status != 'pending')
                  const SizedBox(width: 10),
                if (isCustomer && widget.booking.status == 'in_progress' && widget.booking.paymentStatus != 'paid')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessingPayment ? null : _processPayment,
                      icon: _isProcessingPayment 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.white)
                            )
                          : const Icon(Icons.payment, size: 16),
                      label: const Text('Pay Now', style: TextStyle(fontFamily: 'Lexend', fontSize: 12)),
                    ),
                  ),
                if (!isCustomer && widget.booking.status == 'accepted')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdatingStatus ? null : () => _updateStatus('in_progress'),
                      icon: _isUpdatingStatus
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.white),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Start Job', style: TextStyle(fontFamily: 'Lexend', fontSize: 12)),
                    ),
                  ),
                if (!isCustomer && widget.booking.status == 'in_progress')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGettingPayment ? null : _getPayment,
                      icon: _isGettingPayment 
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.white)
                            )
                          : const Icon(Icons.qr_code, size: 16),
                      label: const Text('Get Payment', style: TextStyle(fontFamily: 'Lexend', fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.booking.status) {
      case 'pending':
        return BrandColors.warning;
      case 'accepted':
        return BrandColors.info;
      case 'in_progress':
        return BrandColors.primaryGreen;
      case 'completed':
        return BrandColors.success;
      case 'cancelled':
        return BrandColors.error;
      default:
        return BrandColors.textMuted;
    }
  }

  String _getStatusLabel() {
    switch (widget.booking.status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return widget.booking.status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays == -1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: BrandColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
