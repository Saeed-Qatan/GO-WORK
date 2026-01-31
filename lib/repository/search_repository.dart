import '../model/home_model.dart';

class SearchRepository {
  Future<List<JobModel>> searchJobs({
    String? query,
    String? category,
    String? location,
    String? type,
  }) async {
    // Artificial delay to mimic API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data
    return [
      JobModel(
        id: '1',
        title: 'React Frontend مطور',
        company: 'شركة التقنية المتقدمة',
        companyLogoUrl: '',
        matchPercentage: 95,
        category: 'تطوير برمجيات',
        location: 'الرياض',
        type: 'دوام كامل',
        workMode: 'حضوري',
        minSalary: '8000',
        maxSalary: '12000',
      ),
      JobModel(
        id: '2',
        title: 'UI/UX Designer',
        company: 'Creative Solutions',
        companyLogoUrl: '',
        matchPercentage: 88,
        category: 'Design',
        location: 'جده',
        type: 'عقد',
        workMode: 'عن بعد',
        minSalary: '5000',
        maxSalary: '9000',
      ),
      JobModel(
        id: '3',
        title: 'Flutter Developer',
        company: 'App Masters',
        companyLogoUrl: '',
        matchPercentage: 92,
        category: 'Mobile Dev',
        location: 'الرياض',
        type: 'دوام كامل',
        workMode: 'هجين',
        minSalary: '10000',
        maxSalary: '15000',
      ),
      JobModel(
        id: '4',
        title: 'Project Manager',
        company: 'BuildIt',
        companyLogoUrl: '',
        matchPercentage: 75,
        category: 'Management',
        location: 'الدمام',
        type: 'دوام كامل',
        workMode: 'حضوري',
        minSalary: '15000',
        maxSalary: '20000',
      ),
      JobModel(
        id: '5',
        title: 'Data Analyst',
        company: 'DataCorp',
        companyLogoUrl: '',
        matchPercentage: 85,
        category: 'Data',
        location: 'عن بعد',
        type: 'بارت تايم',
        workMode: 'عن بعد',
        minSalary: '4000',
        maxSalary: '7000',
      ),
    ].where((job) {
      // Simple local filtering logic
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          job.title.toLowerCase().contains(query.toLowerCase()) ||
          job.company.toLowerCase().contains(query.toLowerCase());

      final matchesCategory =
          category == null ||
          category == 'جميع المجالات' ||
          job.category == category;
      final matchesLocation =
          location == null || location == 'الكل' || job.location == location;
      final matchesType = type == null || type == 'الكل' || job.type == type;

      return matchesQuery && matchesCategory && matchesLocation && matchesType;
    }).toList();
  }
}
