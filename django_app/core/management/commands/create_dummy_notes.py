from django.core.management.base import BaseCommand
from core.models import Note
from core.models import User
import random

WORDS = ("adipisci aliquam amet consectetur dolor dolore dolorem eius est et"
         "incidunt ipsum labore magnam modi neque non numquam porro quaerat qui"
         "quia quisquam sed sit tempora ut velit voluptatem").split()

class TextLorem():
    def __init__(self, wsep=' ', ssep=' ', psep='\n\n',
                 srange=(4, 8), prange=(5, 10), trange=(3, 6),
                 words=None):
        self._wsep = wsep
        self._ssep = ssep
        self._psep = psep
        self._srange = srange
        self._prange = prange
        self._trange = trange
        if words:
            self._words = words
        else:
            self._words = WORDS

    def sentence(self):
        n = random.randint(*self._srange)
        s = self._wsep.join(self._word() for _ in range(n))
        return s[0].upper() + s[1:] + '.'

    def paragraph(self):
        n = random.randint(*self._prange)
        p = self._ssep.join(self.sentence() for _ in range(n))
        return p

    def text(self):
        n = random.randint(*self._trange)
        t = self._psep.join(self.paragraph() for _ in range(n))
        return t

    def _word(self):
        return random.choice(self._words)
    
lorem_generator = TextLorem()

class Command(BaseCommand):
    help = 'Populate database with sample notes'

    def add_arguments(self, parser):
        parser.add_argument('num_entries', type=int, help='Indicates the number of entries to be created')

    def handle(self, *args, **kwargs):
        num_entries = kwargs['num_entries']

        for _ in range(num_entries):
            # Assuming the first CustomUser as the user for simplicity. Modify as required.
            user = User.objects.first()
            if not user:
                self.stdout.write(self.style.ERROR('Please create at least one CustomUser first.'))
                return

            entry = Note(
                title=lorem_generator.sentence(),
                processed_note=lorem_generator.paragraph(),
                original_note=lorem_generator.paragraph(),
                processed=True,
                user=user
            )
            entry.save()
            entry.tags.add(f'tag{_}')

        self.stdout.write(self.style.SUCCESS(f'Successfully created {num_entries} entries!'))
