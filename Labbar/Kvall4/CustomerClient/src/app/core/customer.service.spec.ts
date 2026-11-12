import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { CustomerService } from './customer.service';
import { AppConfig } from './app-config';

describe('CustomerService', () => {
  let service: CustomerService;
  let http: HttpTestingController;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    http = TestBed.inject(HttpTestingController);
    const config = TestBed.inject(AppConfig);
    const loading = config.load();
    http.expectOne('config.json').flush({ apiBaseUrl: 'https://api.example.test/' });
    await loading;
    service = TestBed.inject(CustomerService);
  });

  afterEach(() => http.verify());

  it('hämtar kunder från konfigurerad adress', () => {
    let result: unknown;
    service.list().subscribe((r) => (result = r));
    const req = http.expectOne('https://api.example.test/customers');
    expect(req.request.method).toBe('GET');
    req.flush([{ id: 'a1', name: 'Ada' }]);
    expect(result).toEqual([{ id: 'a1', name: 'Ada' }]);
  });

  it('skickar ny kund med POST', () => {
    service.create({ name: 'Bo' }).subscribe();
    const req = http.expectOne('https://api.example.test/customers');
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ name: 'Bo' });
    req.flush({ id: 'b2', name: 'Bo' });
  });
});
