import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/repository/search_repository.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/utils/app_error_parser.dart';

void main() {
  group('SearchRepository', () {
    test('parses jobs from Jobs/search data.jobs response', () async {
      final client = _FakeApiClient(response: _searchResponse);
      final repository = SearchRepository(apiClient: client);

      final jobs = await repository.searchJobs();

      expect(client.requestedEndpoint, ApiConstants.searchJobs);
      expect(client.requestedSkipAuth, isFalse);
      expect(jobs, hasLength(2));

      final backendJob = jobs.first;
      expect(backendJob.id, '7');
      expect(backendJob.title, 'Backend Developer');
      expect(backendJob.company, 'Osama Company');
      expect(backendJob.companyLogoUrl, contains('c2f23f47'));
      expect(backendJob.category, 'تطوير البرمجيات');
      expect(backendJob.type, 'FullTime');
      expect(backendJob.workMode, 'OnSite');
      expect(backendJob.country, 'اليمن');
      expect(backendJob.location, 'حضرموت');
      expect(backendJob.minSalary, '1500');
      expect(backendJob.maxSalary, '2500');
      expect(backendJob.postedDate, '2026-04-07T16:22:55.3680188');
    });

    test('uses backend query parameter names and keeps auth enabled', () async {
      final client = _FakeApiClient(response: _searchResponse);
      final repository = SearchRepository(apiClient: client);

      await repository.searchJobs(
        query: 'Backend Developer',
        category: 'تطوير البرمجيات',
        workMode: 'OnSite',
        type: 'FullTime',
        country: 'اليمن',
      );

      final endpoint = Uri.parse(client.requestedEndpoint!);
      expect(endpoint.path, ApiConstants.searchJobs);
      expect(endpoint.queryParameters['query'], 'Backend Developer');
      expect(endpoint.queryParameters['category'], 'تطوير البرمجيات');
      expect(endpoint.queryParameters['locationType'], 'OnSite');
      expect(endpoint.queryParameters['jobType'], 'FullTime');
      expect(endpoint.queryParameters['country'], 'اليمن');
      expect(endpoint.queryParameters.containsKey('type'), isFalse);
      expect(client.requestedSkipAuth, isFalse);
    });

    test('rethrows API errors instead of returning an empty list', () async {
      final error = AppApiException(
        'Unauthorized',
        statusCode: 401,
        data: {'message': 'Unauthorized'},
      );
      final client = _FakeApiClient(error: error);
      final repository = SearchRepository(apiClient: client);

      expect(
        repository.searchJobs(),
        throwsA(
          isA<AppApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test(
      'skips invalid job items without failing the whole response',
      () async {
        final response = <String, dynamic>{
          ..._searchResponse,
          'data': {
            ...(_searchResponse['data'] as Map<String, dynamic>),
            'jobs': [
              'invalid item',
              ...((_searchResponse['data'] as Map<String, dynamic>)['jobs']
                  as List<dynamic>),
            ],
          },
        };
        final client = _FakeApiClient(response: response);
        final repository = SearchRepository(apiClient: client);

        final jobs = await repository.searchJobs();

        expect(jobs, hasLength(2));
        expect(jobs.map((job) => job.id), ['7', '2']);
      },
    );
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.response, this.error});

  final Map<String, dynamic>? response;
  final Object? error;
  String? requestedEndpoint;
  bool? requestedSkipAuth;

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    requestedEndpoint = endpoint;
    requestedSkipAuth = skipAuth;

    final error = this.error;
    if (error != null) throw error;

    return response ?? <String, dynamic>{};
  }
}

final _searchResponse = <String, dynamic>{
  'statusCode': 200,
  'success': true,
  'data': {
    'jobs': [
      {
        'id': 7,
        'title': 'Backend Developer',
        'description': 'We are looking for a skilled Backend Developer.',
        'companyName': 'Osama Company',
        'companyLogoUrl':
            'https://example.com/images/c2f23f47-8891-483b-8ef4.jpeg',
        'category': 'تطوير البرمجيات',
        'jobType': 'FullTime',
        'locationType': 'OnSite',
        'country': 'اليمن',
        'governate': 'حضرموت',
        'minSalary': 1500,
        'maxSalary': 2500,
        'postedDate': '2026-04-07T16:22:55.3680188',
      },
      {
        'id': 2,
        'title': 'مطور واجهات أمامية (ويب)',
        'description': 'أريد مطور وجهات أمامية.',
        'companyName': 'UST',
        'companyLogoUrl': 'https://example.com/images/d10aed0d-6e6b-4ebf.png',
        'category': 'تطوير البرمجيات',
        'jobType': 'FullTime',
        'locationType': 'OnSite',
        'country': 'اليمن',
        'governate': 'حضرموت',
        'minSalary': 170000,
        'maxSalary': 200000,
        'postedDate': '2026-03-03T21:52:37.7539914',
      },
    ],
    'page': 1,
    'pageSize': 30,
    'totalCount': 2,
    'hasNextPage': false,
  },
  'errors': [],
};
