import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_widget.dart';

class BookingScreen extends StatefulWidget {
  final Destination destination;

  const BookingScreen({super.key, required this.destination});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _guests = 2;
  int _nights = 5;
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@email.com');
  final _phoneController = TextEditingController(text: '+1 555 0123');
  final _formKey = GlobalKey<FormState>();

  double get _total =>
      widget.destination.pricePerNight * _nights * (_guests > 1 ? 1.0 + (_guests - 1) * 0.3 : 1.0);
  double get _tax => _total * 0.12;
  double get _grandTotal => _total + _tax;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _confirmBooking() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        destination: widget.destination,
        nights: _nights,
        guests: _guests,
        total: _grandTotal,
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to detail
          Navigator.of(context).pop(); // back to home
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Book Trip'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingSummaryCard(destination: dest),
              const SizedBox(height: 24),
              _TripOptions(
                guests: _guests,
                nights: _nights,
                onGuestsChanged: (v) => setState(() => _guests = v),
                onNightsChanged: (v) => setState(() => _nights = v),
              ),
              const SizedBox(height: 24),
              _PriceSummary(
                pricePerNight: dest.pricePerNight,
                nights: _nights,
                guests: _guests,
                subtotal: _total,
                tax: _tax,
                grandTotal: _grandTotal,
              ),
              const SizedBox(height: 24),
              _GuestInfoForm(
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
              ),
              const SizedBox(height: 32),
              _ConfirmButton(onPressed: _confirmBooking),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  final Destination destination;

  const _BookingSummaryCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  destination.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppTheme.accentColor),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.cardOverlayGradient,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            destination.country,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                RatingWidget(
                  rating: destination.rating,
                  reviewCount: destination.reviewCount,
                  starSize: 14,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    destination.category,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripOptions extends StatelessWidget {
  final int guests;
  final int nights;
  final ValueChanged<int> onGuestsChanged;
  final ValueChanged<int> onNightsChanged;

  const _TripOptions({
    required this.guests,
    required this.nights,
    required this.onGuestsChanged,
    required this.onNightsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Options',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          _CounterRow(
            icon: Icons.people_outline,
            label: 'Guests',
            value: guests,
            min: 1,
            max: 10,
            onChanged: onGuestsChanged,
          ),
          const Divider(height: 24),
          _CounterRow(
            icon: Icons.nights_stay_outlined,
            label: 'Nights',
            value: nights,
            min: 1,
            max: 30,
            onChanged: onNightsChanged,
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textDark)),
        const Spacer(),
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              onTap: value > min ? () => onChanged(value - 1) : null,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            _CounterButton(
              icon: Icons.add,
              onTap: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primaryColor.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.primaryColor : Colors.grey,
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final double pricePerNight;
  final int nights;
  final int guests;
  final double subtotal;
  final double tax;
  final double grandTotal;

  const _PriceSummary({
    required this.pricePerNight,
    required this.nights,
    required this.guests,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 14),
          _PriceRow(
            label: '\$$pricePerNight × $nights nights × $guests guest${guests > 1 ? 's' : ''}',
            value: '\$${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _PriceRow(label: 'Taxes & fees (12%)', value: '\$${tax.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _GuestInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _GuestInfoForm({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guest Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Phone is required' : null,
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onPressed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 22),
              SizedBox(width: 10),
              Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final Destination destination;
  final int nights;
  final int guests;
  final double total;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.destination,
    required this.nights,
    required this.guests,
    required this.total,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 64),
                SizedBox(height: 12),
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _DialogRow(label: 'Destination', value: '${destination.name}, ${destination.country}'),
                const SizedBox(height: 10),
                _DialogRow(label: 'Duration', value: '$nights nights'),
                const SizedBox(height: 10),
                _DialogRow(label: 'Guests', value: '$guests guest${guests > 1 ? 's' : ''}'),
                const SizedBox(height: 10),
                _DialogRow(
                  label: 'Total Paid',
                  value: '\$${total.toStringAsFixed(0)}',
                  highlight: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onDone,
                    child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DialogRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.primaryColor : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
