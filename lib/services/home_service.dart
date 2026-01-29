import 'package:flutter/material.dart';
import '../model/home_model.dart';

class HomeService {
  Future<List<StatModel>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate net
    return [
      StatModel(
        count: '2',
        label:
            'مقابلات', // Using explicit strings here for mock, ideally constants
        icon: Icons.calendar_today,
        color: const Color(0xFF4CAF50), // Green for Calendar
      ),
      StatModel(
        count: '5',
        label: 'قيد المراجعة',
        icon: Icons.access_time_filled,
        color: const Color(0xFFFFC107), // Amber for Review
      ),
      StatModel(
        count: '12',
        label: 'طلبات مرسلة',
        icon: Icons.send,
        color: const Color(0xFF2962FF), // Blue for Sent
      ),
    ];
  }

  Future<List<JobModel>> getRecommendedJobs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      JobModel(
        id: '1',
        title: 'مطور React Frontend',
        company: 'شركة التقنية المتقدمة',
        companyLogoUrl: 'assets/logo1.png', // Placeholder
        matchPercentage: 95,
        category: 'تطوير البرمجيات',
        location: 'الرياض',
        type: 'دوام كامل',
        workMode: 'حضوري',
        minSalary: '8,000',
        maxSalary: '12,000',
      ),
      JobModel(
        id: '2',
        title: 'مهندس برمجيات',
        company: 'شركة الحلول التقنية',
        companyLogoUrl: 'assets/logo2.png', // Placeholder
        matchPercentage: 88,
        category: 'تطوير البرمجيات',
        location: 'دبي',
        type: 'دوام كامل',
        workMode: 'عن بعد',
        minSalary: '15,000',
        maxSalary: '20,000',
      ),
      JobModel(
        id: '3',
        title: 'مطور Flutter',
        company: 'تكنولوجيا الابتكار',
        companyLogoUrl: 'assets/logo3.png',
        matchPercentage: 92,
        category: 'تطوير تطبيقات الجوال',
        location: 'جدة',
        type: 'دوام كامل',
        workMode: 'هجين',
        minSalary: '10,000',
        maxSalary: '15,000',
      ),
      JobModel(
        id: '4',
        title: 'مصمم UI/UX',
        company: 'استوديو التصميم الإبداعي',
        companyLogoUrl: 'assets/logo4.png',
        matchPercentage: 85,
        category: 'التصميم',
        location: 'أبوظبي',
        type: 'دوام جزئي',
        workMode: 'عن بعد',
        minSalary: '6,000',
        maxSalary: '9,000',
      ),
      JobModel(
        id: '5',
        title: 'مدير مشاريع تقنية',
        company: 'مجموعة الأعمال الرقمية',
        companyLogoUrl: 'assets/logo5.png',
        matchPercentage: 78,
        category: 'إدارة المشاريع',
        location: 'الدمام',
        type: 'دوام كامل',
        workMode: 'حضوري',
        minSalary: '18,000',
        maxSalary: '25,000',
      ),
    ];
  }
}
